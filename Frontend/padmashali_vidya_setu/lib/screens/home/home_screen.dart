import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/member_models.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

/// Member home: welcome, profile completion by section, quick links, and the (initially empty)
/// notifications / announcements / opportunities / programs feeds.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final member = session.selectedMember;
    if (member == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final dashboard = ref.watch(dashboardProvider(member.registrationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if ((session.account?.members.length ?? 0) > 1) _MemberSwitcher(session: session),
          _AccountMenu(canAddMember: session.account?.canAddMember ?? false),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardProvider(member.registrationId));
          await ref.read(sessionProvider.notifier).refreshAccount();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveBody(
              maxWidth: 720,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeCard(member: member),
                  const SizedBox(height: 16),
                  dashboard.when(
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (e, _) => ErrorBanner(
                      message: describeError(l10n, e),
                      onRetry: () => ref.invalidate(dashboardProvider(member.registrationId)),
                    ),
                    data: (d) => _ProfileCompletionCard(dashboard: d),
                  ),
                  const SizedBox(height: 16),
                  _QuickLinks(member: member, canAddMember: session.account?.canAddMember ?? false),
                  const SizedBox(height: 16),
                  _EmptyFeedCard(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    message: l10n.noNotifications,
                  ),
                  const SizedBox(height: 16),
                  _EmptyFeedCard(
                    icon: Icons.campaign_outlined,
                    title: l10n.announcements,
                    message: l10n.noAnnouncements,
                  ),
                  const SizedBox(height: 16),
                  _EmptyFeedCard(
                    icon: Icons.workspace_premium_outlined,
                    title: l10n.opportunities,
                    message: l10n.noOpportunities,
                  ),
                  const SizedBox(height: 16),
                  _EmptyFeedCard(icon: Icons.event_outlined, title: l10n.upcomingPrograms, message: l10n.noPrograms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.member});
  final MemberSummary member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeGreeting(member.fullName.split(' ').first),
              key: const Key('homeGreeting'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              member.registrationId,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({required this.dashboard});
  final MemberDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectionCard(
      key: const Key('profileCompletionCard'),
      title: l10n.yourProfile,
      icon: Icons.account_circle_outlined,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.profileCompletion, style: theme.textTheme.titleSmall)),
            Text(
              l10n.percentComplete(dashboard.overallPercent),
              key: const Key('overallPercent'),
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: dashboard.overallPercent / 100, minHeight: 12),
        ),
        const SizedBox(height: 12),
        for (final s in dashboard.sections) _SectionRow(section: s),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});
  final ProfileSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final (String label, Color color, IconData icon) = switch (section.status) {
      SectionStatus.complete => (l10n.statusComplete, Colors.green.shade700, Icons.check_circle),
      SectionStatus.inProgress => (l10n.statusInProgress(section.percent), scheme.tertiary, Icons.timelapse),
      SectionStatus.notApplicable => (l10n.statusNotApplicable, scheme.outline, Icons.remove_circle_outline),
      SectionStatus.notStarted => (
        section.isAvailable ? l10n.statusNotStarted : l10n.comingSoon,
        scheme.outline,
        Icons.radio_button_unchecked,
      ),
    };

    return ListTile(
      key: Key('section-${section.key}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(section.title),
      trailing: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: section.isAvailable || section.status == SectionStatus.notApplicable
          ? null
          : () => showSnack(context, l10n.sectionComingSoon),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.member, required this.canAddMember});
  final MemberSummary member;
  final bool canAddMember;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCard(
      title: l10n.quickLinks,
      icon: Icons.bolt_outlined,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ActionChip(
              key: const Key('myProfileLink'),
              avatar: const Icon(Icons.badge_outlined),
              label: Text(l10n.myProfile),
              onPressed: () => context.push(Routes.profile(member.registrationId)),
            ),
            if (canAddMember)
              ActionChip(
                key: const Key('addFamilyMemberLink'),
                avatar: const Icon(Icons.person_add_alt_outlined),
                label: Text(l10n.addFamilyMember),
                onPressed: () => context.push(Routes.register),
              ),
          ],
        ),
      ],
    );
  }
}

class _EmptyFeedCard extends StatelessWidget {
  const _EmptyFeedCard({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: title,
    icon: icon,
    children: [Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))],
  );
}

class _MemberSwitcher extends ConsumerWidget {
  const _MemberSwitcher({required this.session});
  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    tooltip: context.l10n.switchMember,
    icon: const Icon(Icons.switch_account_outlined),
    initialValue: session.selectedMember?.registrationId,
    onSelected: (id) => ref.read(sessionProvider.notifier).selectMember(id),
    itemBuilder: (_) => [
      for (final m in session.account!.members)
        PopupMenuItem(value: m.registrationId, child: Text('${m.fullName} · ${m.registrationId}')),
    ],
  );
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu({required this.canAddMember});
  final bool canAddMember;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      key: const Key('accountMenu'),
      onSelected: (value) async {
        if (value == 'add') {
          await context.push(Routes.register);
        } else if (value == 'signOut') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(l10n.signOutConfirm),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.signOut)),
              ],
            ),
          );
          if (confirmed ?? false) await ref.read(sessionProvider.notifier).signOut();
        }
      },
      itemBuilder: (_) => [
        if (canAddMember) PopupMenuItem(value: 'add', child: Text(l10n.addFamilyMember)),
        PopupMenuItem(value: 'signOut', child: Text(l10n.signOut)),
      ],
    );
  }
}
