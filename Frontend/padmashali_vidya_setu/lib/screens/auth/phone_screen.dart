import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../utils/phone_countries.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';
import '../../widgets/country_code_picker.dart';
import '../legal/legal_document_screen.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mobile;
  late String _countryCode;
  bool _sending = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    // Coming back via "Change Mobile Number" keeps the previous entry for editing.
    final pending = ref.read(pendingVerificationProvider);
    _mobile = TextEditingController(text: pending?.mobileNumber ?? '');
    _countryCode = pending?.countryCode ?? DialCodes.india;
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
      final challenge = await ref.read(authRepositoryProvider).requestCode(DialCodes.apiNumber(_countryCode, mobile));
      ref.read(pendingVerificationProvider.notifier).state = PendingVerification(
        mobileNumber: mobile,
        countryCode: _countryCode,
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
    final india = _countryCode == DialCodes.india;
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(DialCodes.maxDigits(_countryCode)),
                    ],
                    style: theme.textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      hintText: india ? l10n.phoneHint : l10n.phoneHintInternational,
                      prefixIcon: CountryCodePicker(
                        key: const Key('countryCodePicker'),
                        value: _countryCode,
                        enabled: !_sending,
                        onChanged: (code) => setState(() {
                          _countryCode = code;
                          _serverError = null;
                        }),
                      ),
                      errorText: _serverError,
                      errorMaxLines: 3,
                    ),
                    validator: (v) => switch (Validators.mobile(v, countryCode: _countryCode)) {
                      null => null,
                      ValidationIssue.required => l10n.phoneRequired,
                      final issue => issue.text(l10n),
                    },
                    onFieldSubmitted: (_) => _send(),
                  ),
                  if (!india) ...[
                    const SizedBox(height: 16),
                    InfoNote(key: const Key('whatsAppNote'), text: l10n.codeViaWhatsApp, icon: Icons.chat_outlined),
                  ],
                  const SizedBox(height: 16),
                  InfoNote(text: l10n.phoneFamilyNote, icon: Icons.family_restroom_outlined),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    key: const Key('sendCodeButton'),
                    label: l10n.sendVerificationCode,
                    loading: _sending,
                    onPressed: _send,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.agreeByContinuing, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                  LegalLinks(onPrivacy: () => context.push(Routes.privacy), onTerms: () => context.push(Routes.terms)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
