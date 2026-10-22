import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/models/auth_models.dart';
import 'package:padmashali_vidya_setu/models/registration_draft.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/screens/registration/widgets/member_mobile_field.dart';

import '../helpers.dart';

/// Sends "codes" without a network; any code verifies.
class _FakeMemberRepository extends MemberRepository {
  _FakeMemberRepository()
    : super(ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {}));

  final sentTo = <String>[];

  @override
  Future<VerificationChallenge> requestMemberMobileCode(String mobileNumber) async {
    sentTo.add(mobileNumber);
    return VerificationChallenge(
      challengeId: 'challenge-${sentTo.length}',
      maskedMobileNumber: '+91******${mobileNumber.substring(6)}',
      codeLength: 4,
      expiresInSeconds: 600,
      resendAfterSeconds: 0,
    );
  }

  @override
  Future<String> verifyMemberMobileCode(String challengeId, String code) async => challengeId;
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
        child: MemberMobileField(draft: draft, onChanged: () {}),
      ),
      overrides: [...testOverrides(), memberRepositoryProvider.overrideWithValue(repo)],
    );
  }

  Future<bool> validate(WidgetTester tester) async {
    final ok = formKey.currentState!.validate();
    await tester.pumpAndSettle();
    return ok;
  }

  testWidgets('is optional: empty passes and sends no number', (tester) async {
    await pump(tester);
    expect(await validate(tester), isTrue);
    expect(draft.toJson(otherDisabilityTypeId: null)['mobileNumber'], isNull);
    expect(find.byKey(const Key('memberMobileVerifyButton')), findsNothing);
  });

  testWidgets('an invalid number is rejected', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('memberMobileField')), '12345');
    expect(await validate(tester), isFalse);
    expect(find.text('Please enter a valid 10-digit mobile number.'), findsOneWidget);
  });

  testWidgets('a number must be verified with the code before continuing', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('memberMobileField')), '9876543210');
    await tester.pumpAndSettle();
    expect(await validate(tester), isFalse);
    expect(find.text('Verify this mobile number, or leave it empty.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memberMobileVerifyButton')));
    await tester.pumpAndSettle();
    expect(repo.sentTo, ['9876543210']);
    expect(find.text('Enter the 4-digit code sent to +91******3210.'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).last, '4321');
    await tester.pumpAndSettle();

    expect(find.text('Verified'), findsOneWidget);
    expect(await validate(tester), isTrue);
    final json = draft.toJson(otherDisabilityTypeId: null);
    expect(json['mobileNumber'], '9876543210');
    expect(json['mobileVerificationId'], 'challenge-1');
  });

  testWidgets('changing a verified number needs a new verification', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('memberMobileField')), '9876543210');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('memberMobileVerifyButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, '4321');
    await tester.pumpAndSettle();
    expect(draft.mobileIsVerified, isTrue);

    await tester.enterText(find.byKey(const Key('memberMobileField')), '9876543211');
    await tester.pumpAndSettle();
    expect(draft.mobileIsVerified, isFalse);
    expect(draft.toJson(otherDisabilityTypeId: null)['mobileVerificationId'], isNull);
    expect(find.byKey(const Key('memberMobileVerifyButton')), findsOneWidget);
  });
}
