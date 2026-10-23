import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../models/auth_models.dart';
import '../../../models/registration_draft.dart';
import '../../../providers/providers.dart';
import '../../../utils/l10n.dart';
import '../../../utils/validators.dart';
import '../../../widgets/code_input.dart';

/// The member's email address - optional. When one is entered it must be verified with its own code (separate from
/// the mobile number's): "Verify" emails a code, the code is entered here, and the field shows "Verified". Editing
/// the address afterwards needs a new verification. The step cannot continue with an unverified address (clear it to
/// skip).
class MemberEmailField extends ConsumerStatefulWidget {
  const MemberEmailField({super.key, required this.draft, required this.onChanged, this.serverError});

  final RegistrationDraft draft;
  final VoidCallback onChanged;
  final String? serverError;

  @override
  ConsumerState<MemberEmailField> createState() => _MemberEmailFieldState();
}

class _MemberEmailFieldState extends ConsumerState<MemberEmailField> {
  late final _email = TextEditingController(text: widget.draft.email);
  final _code = TextEditingController();

  EmailChallenge? _challenge;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _timer;

  RegistrationDraft get _draft => widget.draft;
  bool get _emailValid => Validators.email(_draft.email) == null;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _emailChanged(String value) {
    setState(() {
      _draft.email = value;
      // A different address needs its own verification.
      if (_draft.verifiedEmail != _draft.emailTrimmed) {
        _challenge = null;
        _code.clear();
        _error = null;
      }
    });
    widget.onChanged();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await ref.read(memberRepositoryProvider).requestMemberEmailCode(_draft.emailTrimmed);
      if (!mounted) return;
      _code.clear();
      setState(() => _challenge = challenge);
      _startCooldown(challenge.resendAfterSeconds);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.fieldErrors['email'] ?? describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final challenge = _challenge;
    if (challenge == null || _code.text.length != challenge.codeLength) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await ref.read(memberRepositoryProvider).verifyMemberEmailCode(challenge.challengeId, _code.text);
      if (!mounted) return;
      setState(() {
        _draft.emailVerificationId = id;
        _draft.verifiedEmail = _draft.emailTrimmed;
        _challenge = null;
      });
      _timer?.cancel();
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) {
        _code.clear();
        setState(() => _error = e.fieldErrors['code'] ?? describeError(l10n, e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _resendIn = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _resendIn <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendIn = 0);
        return;
      }
      setState(() => _resendIn--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final verified = _draft.emailIsVerified;
    final challenge = _challenge;

    Widget? suffix;
    if (verified) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 4),
            Text(l10n.memberMobileVerified, style: TextStyle(color: theme.colorScheme.primary)),
          ],
        ),
      );
    } else if (_draft.hasEmail && _emailValid && challenge == null) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: TextButton(
          key: const Key('memberEmailVerifyButton'),
          onPressed: _busy ? null : _send,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.memberMobileVerify),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('memberEmailField'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.memberEmailLabel,
            helperText: verified || challenge != null ? null : l10n.memberEmailHelp,
            helperMaxLines: 3,
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: suffix,
            errorText: widget.serverError,
            errorMaxLines: 2,
          ),
          validator: (_) {
            if (!_draft.hasEmail) return null; // optional
            final issue = Validators.email(_draft.email);
            if (issue != null) return issue.text(l10n);
            return _draft.emailIsVerified ? null : l10n.memberEmailNeedsVerification;
          },
          onChanged: _emailChanged,
        ),
        if (challenge != null && !verified) ...[
          const SizedBox(height: 12),
          Text(l10n.memberEmailCodeSent(challenge.maskedEmail), style: theme.textTheme.bodyMedium),
          if (challenge.developmentCode != null)
            Text(
              'Development code: ${challenge.developmentCode}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary),
            ),
          const SizedBox(height: 8),
          CodeInput(
            key: const Key('memberEmailCodeInput'),
            controller: _code,
            length: challenge.codeLength,
            semanticLabel: l10n.codeFieldLabel,
            hasError: _error != null,
            onCompleted: (_) => _verify(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy || _resendIn > 0 ? null : _send,
              child: Text(_resendIn > 0 ? l10n.resendIn(_resendIn) : l10n.resendCode),
            ),
          ),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ),
      ],
    );
  }
}
