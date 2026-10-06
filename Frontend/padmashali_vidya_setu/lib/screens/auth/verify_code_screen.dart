import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/code_input.dart';
import '../../widgets/common.dart';

/// "Phone Number Verification" — enter the 4-digit code.
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _resendIn = 0;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    final pending = ref.read(pendingVerificationProvider);
    if (pending == null) return;
    final elapsed = DateTime.now().difference(pending.issuedAt).inSeconds;
    _resendIn = (pending.challenge.resendAfterSeconds - elapsed).clamp(0, 600);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn = _resendIn > 0 ? _resendIn - 1 : 0);
      if (_resendIn == 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final pending = ref.read(pendingVerificationProvider);
    if (pending == null || _verifying) return;
    if (_code.text.length != pending.challenge.codeLength) {
      setState(() => _error = l10n.codeIncomplete);
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).verifyCode(pending.challenge.challengeId, _code.text);
      // The router then redirects to registration or home based on the new session.
      await ref.read(sessionProvider.notifier).signIn(result);
    } on ApiException catch (e) {
      _code.clear();
      setState(() => _error = e.fieldErrors['code'] ?? describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    final pending = ref.read(pendingVerificationProvider);
    if (pending == null) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final challenge = await ref.read(authRepositoryProvider).requestCode(pending.mobileNumber);
      ref.read(pendingVerificationProvider.notifier).state = PendingVerification(
        mobileNumber: pending.mobileNumber,
        challenge: challenge,
        issuedAt: DateTime.now(),
      );
      _code.clear();
      _startCountdown();
      if (mounted) showSnack(context, context.l10n.codeResent);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pending = ref.watch(pendingVerificationProvider);
    if (pending == null) {
      // Opened without a pending verification (e.g. after a restart): start again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.phone);
      });
      return const Scaffold();
    }
    final devCode = pending.challenge.developmentCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.verified_user_outlined, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.verifyInstruction(pending.challenge.maskedMobileNumber),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                CodeInput(
                  controller: _code,
                  length: pending.challenge.codeLength,
                  semanticLabel: l10n.codeFieldLabel,
                  hasError: _error != null,
                  onCompleted: (_) => _verify(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    key: const Key('codeError'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                if (devCode != null) ...[
                  const SizedBox(height: 20),
                  InfoNote(text: l10n.developmentCodeBanner(devCode), icon: Icons.developer_mode),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  key: const Key('verifyButton'),
                  label: l10n.verifyButton,
                  loading: _verifying,
                  onPressed: _verify,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _resendIn > 0 || _resending ? null : _resend,
                  child: Text(_resendIn > 0 ? l10n.resendIn(_resendIn) : l10n.resendCode),
                ),
                TextButton(onPressed: () => context.go(Routes.phone), child: Text(l10n.changeMobileNumber)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
