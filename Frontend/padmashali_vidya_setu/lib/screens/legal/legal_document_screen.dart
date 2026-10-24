import 'package:flutter/material.dart';

import '../../legal/legal_documents.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

/// A full-page legal document (Privacy Policy or Terms and Conditions). Reachable without signing in.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (LegalDocuments.draft) ...[
                    InfoNote(key: const Key('legalDraftNote'), text: l10n.legalDraftNote, icon: Icons.edit_note),
                    const SizedBox(height: 16),
                  ],
                  Text(l10n.legalLastUpdated(document.lastUpdated), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(document.intro, style: theme.textTheme.bodyLarge),
                  for (final section in document.sections) ...[
                    const SizedBox(height: 20),
                    Text(section.heading, style: theme.textTheme.titleMedium),
                    for (final paragraph in section.paragraphs) ...[
                      const SizedBox(height: 8),
                      Text(paragraph, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Privacy Policy · Terms and Conditions" links (+ "Contact us" when [onContact] is set), used on the sign-in
/// screens and in registration.
class LegalLinks extends StatelessWidget {
  const LegalLinks({
    super.key,
    required this.onPrivacy,
    required this.onTerms,
    this.onContact,
    this.alignment = WrapAlignment.center,
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback? onContact;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(key: const Key('privacyPolicyLink'), onPressed: onPrivacy, child: Text(l10n.privacyPolicy)),
        const Text('·'),
        TextButton(key: const Key('termsLink'), onPressed: onTerms, child: Text(l10n.termsAndConditions)),
        if (onContact != null) ...[
          const Text('·'),
          TextButton(key: const Key('contactLink'), onPressed: onContact, child: Text(l10n.contactTitle)),
        ],
      ],
    );
  }
}
