import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/models/auth_models.dart';
import 'package:padmashali_vidya_setu/models/registration_draft.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/screens/registration/widgets/member_email_field.dart';

import '../helpers.dart';

/// Emails "codes" without a network; any code verifies.
class _FakeMemberRepository extends MemberRepository {
  _FakeMemberRepository()
    : super(ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {}));

  final sentTo = <String>[];

  @override
  Future<EmailChallenge> requestMemberEmailCode(String email) async {
    sentTo.add(email);
    return EmailChallenge(
      challengeId: 'email-challenge-${sentTo.length}',
      maskedEmail: 'ka****@example.com',
      codeLength: 4,
      resendAfterSeconds: 0,
    );
  }

  @override
  Future<String> verifyMemberEmailCode(String challengeId, String code) async => challengeId;
}

void main() {
  late RegistrationDraft draft;
  late _FakeMemberRepository repo;
  final formKey = GlobalKey<FormState>();

  Future<void> pump(WidgetTester tester) async {
    draft = RegistrationDraft();
    repo = _FakeMemberRepository();
    await pumpLocalized(
      tester,
      Form(
        key: formKey,
        child: MemberEmailField(draft: draft, onChanged: () {}),
      ),
      overrides: [...testOverrides(), memberRepositoryProvider.overrideWithValue(repo)],
    );
  }

  Future<bool> validate(WidgetTester tester) async {
    final ok = formKey.currentState!.validate();
    await tester.pumpAndSettle();
    return ok;
  }

  testWidgets('is optional: empty passes and sends no email', (tester) async {
    await pump(tester);
    expect(await validate(tester), isTrue);
    final json = draft.toJson(otherDisabilityTypeId: null);
    expect(json['email'], isNull);
    expect(json['emailVerificationId'], isNull);
  });

  testWidgets('an invalid or unverified address blocks the step', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('memberEmailField')), 'not-an-email');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('memberEmailVerifyButton')), findsNothing);
    expect(await validate(tester), isFalse);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('memberEmailField')), 'kavya@example.com');
    await tester.pumpAndSettle();
    expect(await validate(tester), isFalse);
    expect(find.text('Verify this email address, or leave it empty.'), findsOneWidget);
  });

  testWidgets('verified with its own code, then sent with the registration', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('memberEmailField')), ' Kavya@Example.com ');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('memberEmailVerifyButton')));
    await tester.pumpAndSettle();
    expect(repo.sentTo, ['kavya@example.com']);
    expect(find.text('Enter the 4-digit code sent to ka****@example.com.'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).last, '4321');
    await tester.pumpAndSettle();

    expect(find.text('Verified'), findsOneWidget);
    expect(await validate(tester), isTrue);
    final json = draft.toJson(otherDisabilityTypeId: null);
    expect(json['email'], 'kavya@example.com');
    expect(json['emailVerificationId'], 'email-challenge-1');

    // Changing the address needs a new verification.
    await tester.enterText(find.byKey(const Key('memberEmailField')), 'other@example.com');
    await tester.pumpAndSettle();
    expect(draft.emailIsVerified, isFalse);
    expect(draft.toJson(otherDisabilityTypeId: null)['emailVerificationId'], isNull);
  });
}
