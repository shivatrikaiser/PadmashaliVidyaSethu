import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mobile;
  bool _sending = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    // Coming back via "Change Mobile Number" keeps the previous entry for editing.
    _mobile = TextEditingController(text: ref.read(pendingVerificationProvider)?.mobileNumber ?? '');
  }

  @override
  void dispose() {
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    final mobile = Validators.digitsOnly(_mobile.text);
    setState(() => _sending = true);
    try {
      final challenge = await ref.read(authRepositoryProvider).requestCode(mobile);
      ref.read(pendingVerificationProvider.notifier).state = PendingVerification(
        mobileNumber: mobile,
        challenge: challenge,
        issuedAt: DateTime.now(),
      );
      if (mounted) await context.push(Routes.verify);
    } on ApiException catch (e) {
      setState(() => _serverError = e.fieldErrors['mobileNumber'] ?? describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.phoneTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.phone_android_rounded, size: 56, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.phoneSubtitle, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('mobileField'),
                    controller: _mobile,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumberNational],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    style: theme.textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      hintText: l10n.phoneHint,
                      prefixText: '+91  ',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      errorText: _serverError,
                      errorMaxLines: 3,
                    ),
                    validator: (v) => switch (Validators.mobile(v)) {
                      null => null,
                      ValidationIssue.required => l10n.phoneRequired,
                      final issue => issue.text(l10n),
                    },
                    onFieldSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: 16),
                  InfoNote(text: l10n.phoneFamilyNote, icon: Icons.family_restroom_outlined),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    key: const Key('sendCodeButton'),
                    label: l10n.sendVerificationCode,
                    loading: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
