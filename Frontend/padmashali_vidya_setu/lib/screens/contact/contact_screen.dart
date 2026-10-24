import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/contact_info.dart';
import '../../core/api/api_exception.dart';
import '../../providers/providers.dart';
import '../../utils/l10n.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';

/// Contact us: the Sangha office (tap to call, email or open the map), app support, and a short message form that
/// goes to the shared enquiry service (POST /api/v1/enquiries; emailed to support). Reachable without signing in.
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();

  /// The API treats forms sent within a few seconds of appearing as automated.
  final _opened = DateTime.now();
  bool _consent = false;
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  static Future<void> _open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      setState(() => _error = l10n.contactConsentRequired);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(enquiryRepositoryProvider)
          .send(
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            message: _message.text,
            elapsed: DateTime.now().difference(_opened),
          );
      if (mounted) setState(() => _sent = true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.fieldErrors.values.firstOrNull ?? describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: l10n.contactSanghaTitle,
                  icon: Icons.account_balance_outlined,
                  children: [
                    Text(ContactInfo.sanghaName, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _ContactTile(
                      key: const Key('contactAddress'),
                      icon: Icons.location_on_outlined,
                      text: ContactInfo.sanghaAddress,
                      onTap: () => _open(
                        Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': ContactInfo.sanghaAddress}),
                      ),
                    ),
                    _ContactTile(
                      key: const Key('contactPhone'),
                      icon: Icons.phone_outlined,
                      text: ContactInfo.sanghaPhone,
                      onTap: () => _open(Uri(scheme: 'tel', path: '+91${ContactInfo.sanghaPhone}')),
                    ),
                    _ContactTile(
                      key: const Key('contactEmail'),
                      icon: Icons.email_outlined,
                      text: ContactInfo.sanghaEmail,
                      onTap: () => _open(Uri(scheme: 'mailto', path: ContactInfo.sanghaEmail)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: l10n.contactSupportTitle,
                  icon: Icons.support_agent_outlined,
                  children: [
                    Text(l10n.contactSupportText),
                    const SizedBox(height: 8),
                    _ContactTile(
                      key: const Key('contactSupportEmail'),
                      icon: Icons.email_outlined,
                      text: ContactInfo.appSupportEmail,
                      onTap: () => _open(Uri(scheme: 'mailto', path: ContactInfo.appSupportEmail)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: l10n.contactFormTitle,
                  icon: Icons.chat_bubble_outline,
                  children: [if (_sent) _sentNote(context) else _form(context)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sentNote(BuildContext context) =>
      InfoNote(key: const Key('contactSent'), text: context.l10n.contactSent, icon: Icons.check_circle_outline);

  Widget _form(BuildContext context) {
    final l10n = context.l10n;
    final hasContact = _email.text.trim().isNotEmpty || _phone.text.trim().isNotEmpty;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('contactName'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            decoration: InputDecoration(labelText: l10n.contactName, counterText: ''),
            validator: (v) => Validators.tidy(v).length < 2 ? l10n.validationNameTooShort : null,
          ),
          const FieldGap(),
          Text(l10n.contactEmailOrPhone, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('contactEmailField'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return hasContact ? null : l10n.contactEmailOrPhoneRequired;
              return Validators.email(v)?.text(l10n);
            },
          ),
          const FieldGap(),
          TextFormField(
            key: const Key('contactPhoneField'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            maxLength: 20,
            decoration: InputDecoration(labelText: l10n.phoneLabel, counterText: ''),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              final digits = Validators.digitsOnly(v ?? '');
              if (digits.isEmpty) return null;
              return digits.length < 7 ? l10n.phoneInvalidInternational : null;
            },
          ),
          const FieldGap(),
          TextFormField(
            key: const Key('contactMessage'),
            controller: _message,
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(labelText: l10n.contactMessage, alignLabelWithHint: true),
            validator: (v) => (v ?? '').trim().length < 10 ? l10n.contactMessageTooShort : null,
          ),
          CheckboxListTile(
            key: const Key('contactConsent'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _consent,
            title: Text(l10n.contactConsent),
            onChanged: _sending ? null : (v) => setState(() => _consent = v ?? false),
          ),
          if (_error != null) ...[ErrorBanner(message: _error!), const SizedBox(height: 12)],
          PrimaryButton(key: const Key('contactSend'), label: l10n.contactSend, loading: _sending, onPressed: _send),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({super.key, required this.icon, required this.text, required this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(text),
    onTap: onTap,
  );
}
