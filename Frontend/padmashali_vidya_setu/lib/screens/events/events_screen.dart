import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/event_models.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

final eventDateFormat = DateFormat('dd MMM yyyy');

/// Events the selected family member can register for (only those with a group for their age and gender), and the
/// ones they are registered for. Families switch member here to register each person.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final member = session.selectedMember;
    if (member == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final events = ref.watch(memberEventsProvider(member.registrationId));
    final members = session.account?.members ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(memberEventsProvider(member.registrationId).future),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveBody(
              maxWidth: 720,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (members.length > 1) ...[
                    DropdownButtonFormField<String>(
                      key: const Key('eventsMemberChooser'),
                      initialValue: member.registrationId,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.eventsChooseMember),
                      items: [
                        for (final m in members)
                          DropdownMenuItem(
                            value: m.registrationId,
                            child: Text('${m.fullName} · ${m.registrationId}', overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (id) {
                        if (id != null) ref.read(sessionProvider.notifier).selectMember(id);
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text(l10n.eventsFor(member.fullName), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                  ],
                  events.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => ErrorBanner(
                      message: describeError(l10n, e),
                      onRetry: () => ref.invalidate(memberEventsProvider(member.registrationId)),
                    ),
                    data: (list) => list.isEmpty
                        ? InfoNote(key: const Key('noEvents'), text: l10n.noEvents(member.fullName))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [for (final e in list) EventCard(event: e)],
                          ),
                  ),
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

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});
  final MemberEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: Key('event-${event.eventId}'),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(Routes.event(event.eventId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              _IconLine(icon: Icons.event_outlined, text: eventDateFormat.format(event.eventDate)),
              if (event.venue != null) _IconLine(icon: Icons.place_outlined, text: event.venue!),
              const SizedBox(height: 10),
              EventStatusChip(event: event),
            ],
          ),
        ),
      ),
    );
  }
}

/// Registered (with the number) / registration open / opens on ... / closed.
class EventStatusChip extends StatelessWidget {
  const EventStatusChip({super.key, required this.event});
  final MemberEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (String label, Color background, Color foreground, IconData icon) = switch (event) {
      MemberEvent(registration: final r?) => (
        l10n.eventRegisteredChip(r.registrationNumber),
        Colors.green.shade50,
        Colors.green.shade800,
        Icons.check_circle,
      ),
      MemberEvent(isRegistrationOpen: true) => (
        l10n.eventRegistrationOpen,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.how_to_reg_outlined,
      ),
      MemberEvent(opensLater: true) => (
        l10n.eventOpensOn(eventDateFormat.format(event.registrationOpensDate)),
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        Icons.schedule,
      ),
      _ => (l10n.eventRegistrationClosed, scheme.surfaceContainerHighest, scheme.onSurfaceVariant, Icons.lock_outline),
    };
    return Chip(
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600)),
      backgroundColor: background,
      side: BorderSide.none,
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
