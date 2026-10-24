import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/screens/contact/contact_screen.dart';

import '../helpers.dart';

/// Records messages instead of calling the enquiry service.
class _FakeEnquiryRepository extends EnquiryRepository {
  _FakeEnquiryRepository()
    : super(ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {}));

  final sent = <Map<String, Object?>>[];

  @override
  Future<void> send({
    required String name,
    required String email,
    required String phone,
    required String message,
    required Duration elapsed,
  }) async => sent.add({'name': name, 'email': email, 'phone': phone, 'message': message});
}

void main() {
  late _FakeEnquiryRepository repo;

  Future<void> pump(WidgetTester tester) async {
    repo = _FakeEnquiryRepository();
    await pumpLocalized(
      tester,
      const SizedBox(height: 2000, child: ContactScreen()),
      overrides: [...testOverrides(), enquiryRepositoryProvider.overrideWithValue(repo)],
    );
  }

  // Typing taps the field first, so it must be scrolled into view.
  Future<void> type(WidgetTester tester, String key, String text) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  Future<void> tapSend(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('contactSend')));
    await tester.tap(find.byKey(const Key('contactSend')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Sangha office and app support', (tester) async {
    await pump(tester);
    expect(find.text('Padmashali Suvarna Mahotsava Bhavana, Adi-Udupi, Udupi - 576103'), findsOneWidget);
    expect(find.text('9741413165'), findsOneWidget);
    expect(find.text('vidyavardhaka@padmashalimahasabha.com'), findsOneWidget);
    expect(find.text('support@iqexplore.com'), findsOneWidget);
  });

  testWidgets('checks the form, needs the consent tick, then sends and thanks', (tester) async {
    await pump(tester);

    await tapSend(tester);
    expect(find.text('Please give an email address or a phone number.'), findsOneWidget);
    expect(find.text('Please write at least 10 characters.'), findsOneWidget);
    expect(repo.sent, isEmpty);

    await type(tester, 'contactName', 'Asha Rao');
    await type(tester, 'contactPhoneField', '9876543210');
    await type(tester, 'contactMessage', 'When is the next scholarship camp?');
    await tapSend(tester);
    expect(find.text('Please tick the box to agree that we may use these details to reply.'), findsOneWidget);
    expect(repo.sent, isEmpty);

    await tester.ensureVisible(find.byKey(const Key('contactConsent')));
    await tester.tap(find.byKey(const Key('contactConsent')));
    await tester.pumpAndSettle();
    await tapSend(tester);

    expect(repo.sent.single['phone'], '9876543210');
    expect(repo.sent.single['message'], 'When is the next scholarship camp?');
    expect(find.byKey(const Key('contactSent')), findsOneWidget);
  });
}
