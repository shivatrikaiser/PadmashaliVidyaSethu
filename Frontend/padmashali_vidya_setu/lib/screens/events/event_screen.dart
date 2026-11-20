import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_models.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';
import 'events_screen.dart';

/// One event for the selected member: details, the member's age on the "age as on" date, the groups that fit them,
/// and Register / Save changes / Cancel registration while registration is open.
class EventScreen extends ConsumerWidget {
  const EventScreen({super.key, required this.eventId});
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final member = ref.watch(sessionProvider).selectedMember;
    if (member == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final events = ref.watch(memberEventsProvider(member.registrationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.events)),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ResponsiveBody(
          child: ErrorBanner(
            message: describeError(l10n, e),
            onRetry: () => ref.invalidate(memberEventsProvider(member.registrationId)),
          ),
        ),
        data: (list) {
          final event = list.where((e) => e.eventId == eventId).firstOrNull;
          if (event == null) return ResponsiveBody(child: InfoNote(text: l10n.eventNotAvailable));
          return _EventBody(
            // A new form when the member or their registration changes.
            key: ValueKey('${member.registrationId}-${event.registration?.groupIds}'),
            event: event,
            registrationId: member.registrationId,
            memberName: member.fullName,
          );
        },
      ),
    );
  }
}

class _EventBody extends ConsumerStatefulWidget {
  const _EventBody({super.key, required this.event, required this.registrationId, required this.memberName});
  final MemberEvent event;
  final String registrationId;
  final String memberName;

  @override
  ConsumerState<_EventBody> createState() => _EventBodyState();
}

class _EventBodyState extends ConsumerState<_EventBody> {
  late final Set<int> _selected = {...?widget.event.registration?.groupIds};
  bool _busy = false;
  String? _error;

  MemberEvent get _event => widget.event;
  bool get _single => _event.maxGroupsPerMember == 1;

  void _toggle(int groupId) => setState(() {
    _error = null;
    if (_single) {
      _selected
        ..clear()
        ..add(groupId);
    } else if (!_selected.remove(groupId)) {
      _selected.add(groupId);
    }
  });

  Future<void> _register() async {
    final l10n = context.l10n;
    if (_selected.isEmpty) return setState(() => _error = l10n.eventChooseAtLeastOne);
    if (_selected.length > _event.maxGroupsPerMember) {
      return setState(() => _error = l10n.eventTooManyGroups(_event.maxGroupsPerMember));
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(eventRepositoryProvider)
          .register(widget.registrationId, _event.eventId, _selected.toList());
      ref.invalidate(memberEventsProvider(widget.registrationId));
      if (mounted) context.pushReplacement(Routes.eventRegistered, extra: result);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.eventCancelConfirm(widget.memberName, _event.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.eventKeepRegistration)),
          TextButton(
            key: const Key('confirmCancelRegistration'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.eventCancelRegistration),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(eventRepositoryProvider).cancel(widget.registrationId, _event.eventId);
      if (mounted) showSnack(context, l10n.eventCancelled);
      ref.invalidate(memberEventsProvider(widget.registrationId));
    } catch (e) {
      if (mounted) setState(() => _error = describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final e = _event;
    final registration = e.registration;
    final canChange = e.isRegistrationOpen && !_busy;

    return ListView(
      children: [
        ResponsiveBody(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: EventStatusChip(event: e)),
              const SizedBox(height: 8),
              SectionCard(
                title: e.title,
                icon: Icons.event_outlined,
                children: [
                  _Detail(label: l10n.eventDateLabel, value: eventDateFormat.format(e.eventDate)),
                  if (e.venue != null) _Detail(label: l10n.eventVenueLabel, value: e.venue!),
                  Text(
                    l10n.eventRegistrationDates(
                      eventDateFormat.format(e.registrationOpensDate),
                      eventDateFormat.format(e.registrationClosesDate),
                    ),
                  ),
                  if (e.description != null) ...[const SizedBox(height: 12), Text(e.description!)],
                ],
              ),
              if (registration != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.eventYourRegistration, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        SelectableText(
                          registration.registrationNumber,
                          key: const Key('eventRegistrationNumber'),
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        ),
                        Text(registration.groupNames.join(', ')),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              InfoNote(
                icon: Icons.cake_outlined,
                text: '${widget.memberName} · ${l10n.eventAgeOn(eventDateFormat.format(e.ageAsOnDate), e.age)}',
              ),
              const SizedBox(height: 16),
              Text(
                _single ? l10n.eventChooseGroup : l10n.eventChooseGroups(e.maxGroupsPerMember),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final g in e.groups) _groupTile(g, canChange),
              if (_error != null) ...[const SizedBox(height: 12), ErrorBanner(message: _error!)],
              if (e.isRegistrationOpen) ...[
                const SizedBox(height: 20),
                PrimaryButton(
                  key: const Key('eventRegisterButton'),
                  label: registration == null ? l10n.eventRegister : l10n.eventSaveChanges,
                  loading: _busy,
                  onPressed: _register,
                ),
                if (registration != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('eventCancelButton'),
                    onPressed: _busy ? null : _cancel,
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    child: Text(l10n.eventCancelRegistration),
                  ),
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupTile(EventGroupOption g, bool canChange) {
    final l10n = context.l10n;
    final selected = _selected.contains(g.id);
    // A full group stays available to a member who is already in it.
    final enabled = canChange && (!g.isFull || (_event.registration?.groupIds.contains(g.id) ?? false));
    final subtitle = [
      l10n.eventGroupAges(g.minAge, g.maxAge),
      if (g.gender != null) l10n.eventGroupGenderOnly(g.gender!),
      if (g.isFull) l10n.eventGroupFull,
    ].join(' · ');
    final title = Text(g.name);
    return _single
        ? RadioListTile<int>(
            key: Key('eventGroup-${g.id}'),
            value: g.id,
            // ignore: deprecated_member_use
            groupValue: _selected.firstOrNull,
            // ignore: deprecated_member_use
            onChanged: enabled ? (_) => _toggle(g.id) : null,
            title: title,
            subtitle: Text(subtitle),
            contentPadding: EdgeInsets.zero,
          )
        : CheckboxListTile(
            key: Key('eventGroup-${g.id}'),
            value: selected,
            onChanged: enabled ? (_) => _toggle(g.id) : null,
            title: title,
            subtitle: Text(subtitle),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
