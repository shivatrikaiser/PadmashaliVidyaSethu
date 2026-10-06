import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/models/registration_draft.dart';
import 'package:padmashali_vidya_setu/screens/registration/steps/address_step.dart';
import 'package:padmashali_vidya_setu/screens/registration/steps/current_status_step.dart';
import 'package:padmashali_vidya_setu/screens/registration/steps/disability_step.dart';
import 'package:padmashali_vidya_setu/screens/registration/steps/personal_details_step.dart';

import '../helpers.dart';

void main() {
  group('Current Status step', () {
    Future<RegistrationDraft> pumpStep(WidgetTester tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: CurrentStatusStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );
      return draft;
    }

    testWidgets('defaults to Student and shows Class Studying', (tester) async {
      final draft = await pumpStep(tester);

      expect(draft.memberStatus?.code, 'STUDENT');
      expect(tester.widget<ChoiceChip>(find.byKey(const Key('choice-STUDENT'))).selected, isTrue);
      expect(find.byKey(const Key('classStudyingField')), findsOneWidget);
      expect(find.byKey(const Key('highestEducationField')), findsNothing);
    });

    testWidgets('Working hides Class Studying and asks for Highest Education', (tester) async {
      await pumpStep(tester);

      await tester.tap(find.byKey(const Key('choice-WORKING')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('classStudyingField')), findsNothing);
      expect(find.text('Class Studying'), findsNothing);
      expect(find.byKey(const Key('highestEducationField')), findsOneWidget);
    });

    testWidgets('Unemployed hides Class Studying and asks for Highest Education', (tester) async {
      await pumpStep(tester);

      await tester.tap(find.byKey(const Key('choice-UNEMPLOYED')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('classStudyingField')), findsNothing);
      expect(find.byKey(const Key('highestEducationField')), findsOneWidget);
    });

    testWidgets('switching back to Student shows Class Studying again', (tester) async {
      await pumpStep(tester);

      await tester.tap(find.byKey(const Key('choice-WORKING')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choice-STUDENT')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('classStudyingField')), findsOneWidget);
      expect(find.byKey(const Key('highestEducationField')), findsNothing);
    });

    testWidgets('class must be selected for students', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpLocalized(
        tester,
        Form(
          key: formKey,
          child: CurrentStatusStep(draft: RegistrationDraft(), serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please make a selection.'), findsOneWidget);
    });
  });

  group('Disability step', () {
    Future<RegistrationDraft> pumpStep(WidgetTester tester, {RegistrationDraft? draft}) async {
      final d = draft ?? RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: DisabilityStep(draft: d, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );
      return d;
    }

    testWidgets('defaults to No and hides Type of Disability', (tester) async {
      final draft = await pumpStep(tester);

      expect(draft.isDisabled, isFalse);
      expect(find.byKey(const Key('disabilityTypesField')), findsNothing);
      expect(find.text('Type of Disability'), findsNothing);
    });

    testWidgets('Yes shows Type of Disability; No hides it again', (tester) async {
      await pumpStep(tester);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('disabilityTypesField')), findsOneWidget);
      expect(find.byKey(const Key('disability-HEARING')), findsOneWidget);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('disabilityTypesField')), findsNothing);
    });

    testWidgets('choosing Other asks to specify', (tester) async {
      final draft = await pumpStep(tester);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('otherDisabilityField')), findsNothing);

      await tester.tap(find.byKey(const Key('disability-OTHER')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('otherDisabilityField')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('otherDisabilityField')), 'Low vision');
      expect(draft.otherDisabilityDescription, 'Low vision');
      expect(draft.disabilityTypeIds, {8});
    });

    testWidgets('guardian consent appears only for minors', (tester) async {
      final now = DateTime.now();
      await pumpStep(tester, draft: RegistrationDraft()..dateOfBirth = DateTime(now.year - 10, 1, 1));
      expect(find.byKey(const Key('guardianConsent')), findsOneWidget);
    });

    testWidgets('no guardian consent for adults', (tester) async {
      final now = DateTime.now();
      await pumpStep(tester, draft: RegistrationDraft()..dateOfBirth = DateTime(now.year - 30, 1, 1));
      expect(find.byKey(const Key('guardianConsent')), findsNothing);
      expect(find.byKey(const Key('privacyConsent')), findsOneWidget);
    });
  });

  group('Personal details step', () {
    testWidgets('shows the age calculated from the date of birth', (tester) async {
      final now = DateTime.now();
      final draft = RegistrationDraft()..dateOfBirth = DateTime(now.year - 16, 1, 1);
      await pumpLocalized(
        tester,
        Form(
          child: PersonalDetailsStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );

      final expected = now.month == 1 && now.day < 1 ? 15 : 16;
      expect(find.text('Age: $expected years'), findsOneWidget);
    });

    testWidgets('picking a date of birth updates the age', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: PersonalDetailsStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );
      expect(find.byKey(const Key('ageText')), findsNothing);

      await tester.tap(find.byKey(const Key('dateOfBirthField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(draft.dateOfBirth, isNotNull);
      expect(find.byKey(const Key('ageText')), findsOneWidget);
    });

    testWidgets('required and format validation', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpLocalized(
        tester,
        Form(
          key: formKey,
          child: PersonalDetailsStep(draft: RegistrationDraft(), serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );

      await tester.enterText(find.byKey(const Key('fatherNameField')), 'Suresh123');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('This field is required.'), findsNWidgets(2)); // full name, mother name
      expect(find.text('Use letters, spaces, dots and hyphens only.'), findsOneWidget);
      expect(find.text('Please select the date of birth.'), findsOneWidget);
    });

    testWidgets('server errors are shown on the matching field', (tester) async {
      await pumpLocalized(
        tester,
        Form(
          child: PersonalDetailsStep(
            draft: RegistrationDraft(),
            serverErrors: const {'fullName': 'Name rejected by server'},
            onFieldChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Name rejected by server'), findsOneWidget);
    });
  });

  group('Address step', () {
    testWidgets('valid PIN fills district, state, country and suggests the taluk', (tester) async {
      final repo = FakeMasterDataRepository();
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
        overrides: testOverrides(masterData: repo),
      );

      await tester.enterText(find.byKey(const Key('permanentAddress.pinCode')), '574201');
      await tester.pumpAndSettle();

      expect(repo.pinLookups, 1);
      final a = draft.permanentAddress;
      expect(a.district?.name, 'Dakshina Kannada');
      expect(a.state?.name, 'Karnataka');
      expect(a.country?.name, 'India');
      expect(a.talukId, 3);
      expect(find.text('Dakshina Kannada'), findsOneWidget);
      expect(find.text('Karnataka'), findsOneWidget);
      expect(find.text('Puttur'), findsOneWidget); // taluk dropdown, filtered by district
      expect(find.byKey(const Key('permanentAddress.localityMenu')), findsOneWidget); // several localities
    });

    testWidgets('unknown PIN shows a hint and allows manual selection', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );

      await tester.enterText(find.byKey(const Key('permanentAddress.pinCode')), '999999');
      await tester.pumpAndSettle();

      expect(find.textContaining('could not find this PIN code'), findsOneWidget);
      expect(find.byKey(const Key('permanentAddress.stateId')), findsOneWidget);
    });

    testWidgets('"same as permanent" hides the current address form', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );

      expect(find.text('Current Address'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('sameAsPermanentCheckbox')));
      await tester.tap(find.byKey(const Key('sameAsPermanentCheckbox')));
      await tester.pumpAndSettle();

      expect(draft.currentSameAsPermanent, isTrue);
      expect(find.text('Current Address'), findsNothing);
    });

    testWidgets('taluk not listed switches to a text field', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
      );
      await tester.enterText(find.byKey(const Key('permanentAddress.pinCode')), '574201');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('permanentAddress.talukNotListed')));
      await tester.tap(find.byKey(const Key('permanentAddress.talukNotListed')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('permanentAddress.newTalukName')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('permanentAddress.newTalukName')), 'Kadaba');
      final json = draft.permanentAddress.toJson();
      expect(json['talukId'], isNull);
      expect(json['newTalukName'], 'Kadaba');
    });
  });
}
