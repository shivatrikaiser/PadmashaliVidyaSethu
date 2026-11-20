import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_models.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';
import 'events_screen.dart';

/// Shown after registering (or changing groups): the event registration number, large.
class EventRegisteredScreen extends StatelessWidget {
  const EventRegisteredScreen({super.key, required this.result});

  final EventRegistrationResult? result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final r = result;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveBody(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.check_circle_rounded, size: 96, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.eventRegisteredTitle,
                    key: const Key('eventRegisteredTitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  if (r != null)
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(l10n.eventRegistrationNumberLabel, style: theme.textTheme.titleSmall),
                            const SizedBox(height: 6),
                            SelectableText(
                              r.registrationNumber,
                              key: const Key('eventRegisteredNumber'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(r.eventTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                            Text(
                              [eventDateFormat.format(r.eventDate), if (r.venue != null) r.venue!].join(' · '),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text('${r.memberName} · ${r.registrationId}', textAlign: TextAlign.center),
                            Text(r.groups.join(', '), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  InfoNote(text: l10n.eventRegisteredNote),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    key: const Key('backToEventsButton'),
                    label: l10n.eventBackToEvents,
                    onPressed: () => context.canPop() ? context.pop() : context.go(Routes.events),
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
