import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/l10n/generated/app_localizations.dart';
import 'package:padmashali_vidya_setu/models/event_models.dart';
import 'package:padmashali_vidya_setu/models/member_models.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/routing/routes.dart';
import 'package:padmashali_vidya_setu/screens/events/event_registered_screen.dart';
import 'package:padmashali_vidya_setu/screens/events/event_screen.dart';
import 'package:padmashali_vidya_setu/screens/events/events_screen.dart';
import 'package:padmashali_vidya_setu/theme/app_theme.dart';

import '../helpers.dart';

const _girl = MemberSummary(
  registrationId: 'PVS-01-0002',
  fullName: 'Sumana Shettigar',
  age: 15,
  templeName: 'T',
  memberStatusName: 'Student',
  profileCompletionPercent: 11,
);
const _father = MemberSummary(
  registrationId: 'PVS-01-0001',
  fullName: 'Veerabhadra Shettigar',
  age: 50,
  templeName: 'T',
  memberStatusName: 'Working',
  profileCompletionPercent: 11,
);

MemberEvent _event({
  int id = 7,
  int maxGroups = 1,
  bool open = true,
  MyEventRegistration? registration,
  List<EventGroupOption>? groups,
}) => MemberEvent(
  eventId: id,
  code: 'SPORTS26',
  title: 'Sports Day 2026',
  description: 'Running and relay.',
  venue: 'Temple grounds, Barkur',
  eventDate: DateTime(2026, 12, 20),
  ageAsOnDate: DateTime(2026, 12, 1),
  registrationOpensDate: DateTime(2026, 11, 1),
  registrationClosesDate: DateTime(2026, 12, 10),
  maxGroupsPerMember: maxGroups,
  age: 15,
  isRegistrationOpen: open,
  groups:
      groups ??
      const [
        EventGroupOption(id: 1, name: 'Girls 13-16', minAge: 13, maxAge: 16, gender: 'Female', isFull: false),
        EventGroupOption(id: 2, name: 'Open', minAge: 0, maxAge: 120, isFull: false),
      ],
  registration: registration,
);

ApiClient _offlineApi() =>
    ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {});

class _FamilySession extends SessionNotifier {
  _FamilySession(List<MemberSummary> members)
    : super(tokens: MemoryTokenStorage(), auth: AuthRepository(_offlineApi()), members: MemberRepository(_offlineApi())) {
    state = SessionState(
      status: SessionStatus.signedIn,
      account: MyAccount(maskedMobileNumber: '+91******6699', members: members, maxMembersPerAccount: 10),
    );
  }
}

class _FakeEventRepository extends EventRepository {
  _FakeEventRepository(this.events) : super(_offlineApi());

  /// Events per member registration id.
  final Map<String, List<MemberEvent>> events;
  final registered = <(String, int, List<int>)>[];
  final cancelled = <(String, int)>[];

  @override
  Future<List<MemberEvent>> list(String registrationId) async => events[registrationId] ?? const [];

  @override
  Future<EventRegistrationResult> register(String registrationId, int eventId, List<int> groupIds) async {
    registered.add((registrationId, eventId, groupIds));
    final event = events[registrationId]!.singleWhere((e) => e.eventId == eventId);
    final names = event.groups.where((g) => groupIds.contains(g.id)).map((g) => g.name).toList();
    events[registrationId] = [
      _event(
        id: eventId,
        maxGroups: event.maxGroupsPerMember,
        groups: event.groups,
        registration: MyEventRegistration(registrationNumber: 'SPORTS26-0001', groupIds: groupIds, groupNames: names),
      ),
    ];
    return EventRegistrationResult(
      registrationNumber: 'SPORTS26-0001',
      eventTitle: event.title,
      eventDate: event.eventDate,
      venue: event.venue,
      registrationId: registrationId,
      memberName: 'Sumana Shettigar',
      groups: names,
    );
  }

  @override
  Future<void> cancel(String registrationId, int eventId) async {
    cancelled.add((registrationId, eventId));
    events[registrationId] = [_event(id: eventId)];
  }
}

Future<_FakeEventRepository> _pump(
  WidgetTester tester,
  Map<String, List<MemberEvent>> events, {
  List<MemberSummary> members = const [_girl],
}) async {
  // Tall enough for the whole event screen.
  tester.view.physicalSize = const Size(1080, 4800);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final repo = _FakeEventRepository(events);
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, _) => Scaffold(
          body: Center(
            child: TextButton(onPressed: () => context.push(Routes.events), child: const Text('open events')),
          ),
        ),
      ),
      GoRoute(path: Routes.events, builder: (_, _) => const EventsScreen()),
      GoRoute(
        path: Routes.eventRegistered,
        builder: (_, state) => EventRegisteredScreen(result: state.extra as EventRegistrationResult?),
      ),
      GoRoute(
        path: Routes.eventPattern,
        builder: (_, state) => EventScreen(eventId: int.parse(state.pathParameters['eventId']!)),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(),
        eventRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith((ref) => _FamilySession(members)),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open events'));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('register for an event in the member\'s age group and see the registration number', (tester) async {
    final repo = await _pump(tester, {
      _girl.registrationId: [_event()],
    });

    expect(find.text('Sports Day 2026'), findsOneWidget);
    expect(find.text('Registration open'), findsOneWidget);
    await tester.tap(find.byKey(const Key('event-7')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Age as on 01 Dec 2026: 15 years'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Age 13 to 16 · Female only'), findsOneWidget);

    // Nothing chosen yet.
    await tester.tap(find.byKey(const Key('eventRegisterButton')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a group.'), findsOneWidget);
    expect(repo.registered, isEmpty);

    await tester.tap(find.byKey(const Key('eventGroup-1')));
    await tester.tap(find.byKey(const Key('eventRegisterButton')));
    await tester.pumpAndSettle();

    final (registrationId, eventId, groupIds) = repo.registered.single;
    expect((registrationId, eventId), (_girl.registrationId, 7));
    expect(groupIds, [1]);
    expect(find.byKey(const Key('eventRegisteredTitle')), findsOneWidget);
    expect(find.text('SPORTS26-0001'), findsOneWidget);
    expect(find.text('Girls 13-16'), findsOneWidget);

    // Back on the list, the event shows the number.
    await tester.tap(find.byKey(const Key('backToEventsButton')));
    await tester.pumpAndSettle();
    expect(find.text('Registered · SPORTS26-0001'), findsOneWidget);
  });

  testWidgets('several groups up to the limit; a full group cannot be chosen', (tester) async {
    final repo = await _pump(tester, {
      _girl.registrationId: [
        _event(
          maxGroups: 2,
          groups: const [
            EventGroupOption(id: 1, name: 'Running U16', minAge: 10, maxAge: 16, isFull: false),
            EventGroupOption(id: 2, name: 'Long Jump U16', minAge: 10, maxAge: 16, isFull: false),
            EventGroupOption(id: 3, name: 'Relay U16', minAge: 10, maxAge: 16, isFull: false),
            EventGroupOption(id: 4, name: 'Chess', minAge: 10, maxAge: 16, isFull: true),
          ],
        ),
      ],
    });
    await tester.tap(find.byKey(const Key('event-7')));
    await tester.pumpAndSettle();

    expect(find.text('Choose up to 2 groups'), findsOneWidget);
    final chess = tester.widget<CheckboxListTile>(find.byKey(const Key('eventGroup-4')));
    expect(chess.onChanged, isNull);

    for (final id in [1, 2, 3]) {
      await tester.tap(find.byKey(Key('eventGroup-$id')));
    }
    await tester.tap(find.byKey(const Key('eventRegisterButton')));
    await tester.pumpAndSettle();
    expect(find.text('Choose at most 2 groups.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('eventGroup-3')));
    await tester.tap(find.byKey(const Key('eventRegisterButton')));
    await tester.pumpAndSettle();
    expect(repo.registered.single.$3, [1, 2]);
  });

  testWidgets('a registered member sees the number and can cancel', (tester) async {
    final repo = await _pump(tester, {
      _girl.registrationId: [
        _event(
          registration: const MyEventRegistration(
            registrationNumber: 'SPORTS26-0004',
            groupIds: [2],
            groupNames: ['Open'],
          ),
        ),
      ],
    });
    expect(find.text('Registered · SPORTS26-0004'), findsOneWidget);
    await tester.tap(find.byKey(const Key('event-7')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('eventRegistrationNumber')), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    await tester.tap(find.byKey(const Key('eventCancelButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmCancelRegistration')));
    await tester.pumpAndSettle();

    expect(repo.cancelled.single, (_girl.registrationId, 7));
    expect(find.text('Registration cancelled.'), findsOneWidget);
    expect(find.byKey(const Key('eventRegistrationNumber')), findsNothing);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('closed registration: no buttons, groups read-only', (tester) async {
    await _pump(tester, {
      _girl.registrationId: [_event(open: false)],
    });
    await tester.tap(find.byKey(const Key('event-7')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('eventRegisterButton')), findsNothing);
  });

  testWidgets('families switch member; members without events see a note', (tester) async {
    await _pump(tester, {
      _girl.registrationId: [_event()],
    }, members: const [_father, _girl]);

    // The first member (father) has no event for his age.
    expect(find.byKey(const Key('noEvents')), findsOneWidget);

    await tester.tap(find.byKey(const Key('eventsMemberChooser')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sumana Shettigar · PVS-01-0002').last);
    await tester.pumpAndSettle();
    expect(find.text('Sports Day 2026'), findsOneWidget);
  });
}
