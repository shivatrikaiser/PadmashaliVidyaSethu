import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/member_models.dart';
import '../../providers/providers.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

/// Read-only view of the basic profile captured at registration.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.registrationId});
  final String registrationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider(registrationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ResponsiveBody(
          child: ErrorBanner(
            message: describeError(l10n, e),
            onRetry: () => ref.invalidate(profileProvider(registrationId)),
          ),
        ),
        data: (p) => _ProfileBody(profile: p),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});
  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final date = DateFormat('dd MMM yyyy');
    final p = profile;

    return ListView(
      children: [
        ResponsiveBody(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    child: Text(
                      p.fullName.isEmpty ? '?' : p.fullName[0].toUpperCase(),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  title: Text(p.fullName, style: theme.textTheme.titleLarge),
                  subtitle: Text(
                    '${p.registrationId}\n${l10n.registeredOn(date.format(p.registrationCompletedDate.toLocal()))}',
                  ),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.personalInformation,
                icon: Icons.person_outline,
                children: [
                  _Row(l10n.fatherName, p.fatherName),
                  _Row(l10n.motherName, p.motherName),
                  _Row(l10n.dateOfBirth, date.format(p.dateOfBirth)),
                  _Row(l10n.age, '${p.age}'),
                  _Row(l10n.gender, p.gender),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.educationStatus,
                icon: Icons.school_outlined,
                children: [
                  _Row(l10n.currentStatus, p.memberStatus),
                  if (p.isStudent) _Row(l10n.classStudying, p.schoolClass ?? l10n.notApplicableShort),
                  if (!p.isStudent) _Row(l10n.highestEducation, p.highestEducation ?? l10n.notApplicableShort),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.community,
                icon: Icons.temple_hindu_outlined,
                children: [_Row(l10n.temple, p.temple), _Row(l10n.organisationLabel, p.organisation)],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.addresses,
                icon: Icons.home_outlined,
                children: [
                  for (final a in p.addresses) ...[
                    Text(
                      a.isPermanent ? l10n.permanentAddress : l10n.currentAddress,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        a.addressLine1,
                        if (a.addressLine2 != null) a.addressLine2!,
                        a.cityVillageName,
                        '${l10n.taluk}: ${a.taluk}',
                        '${a.district}, ${a.state} - ${a.pinCode}',
                        a.country,
                      ].join('\n'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.disabilityInformation,
                icon: Icons.accessibility_new_outlined,
                children: [
                  _Row(l10n.isDisabled, p.isDisabled ? l10n.yes : l10n.no),
                  if (p.isDisabled) _Row(l10n.typeOfDisability, p.disabilityTypes.join(', ')),
                ],
              ),
              const SizedBox(height: 16),
              InfoNote(text: l10n.dataCorrectionNote),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
