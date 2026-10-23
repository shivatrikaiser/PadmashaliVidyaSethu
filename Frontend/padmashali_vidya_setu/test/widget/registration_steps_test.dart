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

    testWidgets('Highest Education "Other" asks to specify and sends the text', (tester) async {
      final draft = await pumpStep(tester);
      await tester.tap(find.byKey(const Key('choice-WORKING')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('highestEducationOtherField')), findsNothing);

      await tester.tap(find.byKey(const Key('highestEducationField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('highestEducationOtherField')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('highestEducationOtherField')), ' Diploma in Yoga ');
      final json = draft.toJson(otherDisabilityTypeId: null);
      expect(json['highestEducationLevelId'], 14);
      expect(json['highestEducationLevelOtherText'], 'Diploma in Yoga');
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
      // Several places for the PIN: chosen from a list, not typed.
      expect(find.byKey(const Key('permanentAddress.cityId')), findsOneWidget);
      expect(find.byKey(const Key('permanentAddress.cityVillageName')), findsNothing);
    });

    testWidgets('PIN places are offered as City / Village; "not listed" asks to type it', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
        overrides: testOverrides(masterData: FakeMasterDataRepository()),
      );
      await tester.enterText(find.byKey(const Key('permanentAddress.pinCode')), '574201');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('permanentAddress.cityId')));
      await tester.pumpAndSettle();
      expect(find.text('Bolwar').last, findsOneWidget);
      await tester.tap(find.text('Puttur(D.K.)').last);
      await tester.pumpAndSettle();
      final a = draft.permanentAddress;
      expect(a.toJson()['cityId'], 2);
      expect(a.toJson()['cityVillageName'], 'Puttur(D.K.)');

      await tester.tap(find.byKey(const Key('permanentAddress.cityId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My place is not listed').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('permanentAddress.cityVillageName')), 'Kabaka');
      expect(a.toJson()['cityId'], isNull);
      expect(a.toJson()['cityVillageName'], 'Kabaka');
    });

    Finder permanentPinLabel() =>
        find.descendant(of: find.byKey(const Key('permanentAddress.pinCode')), matching: find.text('PIN Code'));

    Future<void> chooseCountry(WidgetTester tester, String name) async {
      await tester.tap(find.byKey(const Key('permanentAddress.countryId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    testWidgets('country outside India: typed city, state and optional postal code; no PIN flow', (tester) async {
      final repo = FakeMasterDataRepository();
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
        overrides: testOverrides(masterData: repo),
      );
      expect(draft.permanentAddress.country?.name, 'India'); // default

      await chooseCountry(tester, 'United Arab Emirates');

      // No states listed for the country: State / Province is typed straight away.
      expect(permanentPinLabel(), findsNothing); // postal code field instead
      expect(find.text('Postal Code (optional)'), findsOneWidget);
      expect(find.byKey(const Key('permanentAddress.districtId')), findsNothing);
      expect(find.byKey(const Key('permanentAddress.stateNotListed')), findsNothing);
      await tester.enterText(find.byKey(const Key('permanentAddress.addressLine1')), 'Flat 504, Al Nahda Tower');
      await tester.enterText(find.byKey(const Key('permanentAddress.cityVillageName')), 'Dubai');
      await tester.enterText(find.byKey(const Key('permanentAddress.newStateName')), 'Dubai');
      await tester.pumpAndSettle();

      expect(repo.pinLookups, 0);
      final json = draft.permanentAddress.toJson();
      expect(json['countryId'], 2);
      expect(json['newStateName'], 'Dubai');
      expect(json['stateId'], isNull);
      expect(json['pinCode'], isNull);
      expect(json.containsKey('districtId'), isFalse);
      expect(json.containsKey('talukId'), isFalse);
    });

    testWidgets('country outside India with states: chosen from the list, or typed when not listed', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
        overrides: testOverrides(masterData: FakeMasterDataRepository()),
      );
      await chooseCountry(tester, 'United States');

      await tester.tap(find.byKey(const Key('permanentAddress.stateId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('California').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('permanentAddress.pinCode')), '94016');
      final a = draft.permanentAddress;
      expect(a.toJson()['stateId'], 40);
      expect(a.toJson()['pinCode'], '94016');

      await tester.tap(find.byKey(const Key('permanentAddress.stateNotListed')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('permanentAddress.newStateName')), 'Texas');
      expect(a.toJson()['stateId'], isNull);
      expect(a.toJson()['newStateName'], 'Texas');
    });

    testWidgets('switching back to India restores the PIN flow with a clean address', (tester) async {
      final draft = RegistrationDraft();
      await pumpLocalized(
        tester,
        Form(
          child: AddressStep(draft: draft, serverErrors: const {}, onFieldChanged: (_) {}),
        ),
        overrides: testOverrides(masterData: FakeMasterDataRepository()),
      );
      await chooseCountry(tester, 'United Arab Emirates');
      await tester.enterText(find.byKey(const Key('permanentAddress.cityVillageName')), 'Dubai');
      await chooseCountry(tester, 'India');

      expect(permanentPinLabel(), findsOneWidget);
      expect(draft.permanentAddress.cityVillageName, isEmpty);
      expect(draft.permanentAddress.toJson()['countryId'], 1);
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
