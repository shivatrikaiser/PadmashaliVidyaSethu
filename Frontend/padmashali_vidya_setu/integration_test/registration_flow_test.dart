// End-to-end test of the first milestone, against a running development API.
//
//   1. Start the API:      cd Backend/PadmashaliVidyaSetu.Api && dotnet run --launch-profile http
//   2. Start an emulator:  flutter emulators --launch Pixel_7
//   3. Run:                flutter test integration_test -d emulator-5554
//
// Requires the API in Development mode (verification code returned to the app) and internet access
// for the first PIN-code lookup.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:padmashali_vidya_setu/app.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';

/// Set with --dart-define=SCREENSHOTS=true when running through `flutter drive` (see test_driver/).
const _screenshots = bool.fromEnvironment('SCREENSHOTS');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var surfaceConverted = false;

  Future<void> shot(WidgetTester t, String name) async {
    if (!_screenshots) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    if (!surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      surfaceConverted = true;
      await t.pumpAndSettle();
    }
    await binding.takeScreenshot(name);
  }

  testWidgets('Register → verify phone → details → Student/Class → address via PIN → disability → home', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [tokenStorageProvider.overrideWithValue(MemoryTokenStorage())],
      child: const PvsApp(),
    ));

    // ---------------------------------------------------------------- Welcome → Mobile number
    await t.waitFor(find.byKey(const Key('getStartedButton')));
    await shot(t, '01-welcome');
    await t.tapVisible(find.byKey(const Key('getStartedButton')));
    await t.waitFor(find.byKey(const Key('mobileField')));
    expect(find.textContaining('OTP'), findsNothing);

    final mobile = '9${Random().nextInt(900000000) + 100000000}';
    await t.enterText(find.byKey(const Key('mobileField')), mobile);
    await shot(t, '02-phone-number');
    await t.tapVisible(find.byKey(const Key('sendCodeButton')));

    // ---------------------------------------------------------------- 4-digit Phone Number Verification Code
    final devCode = find.textContaining('Development mode: your verification code is');
    await t.waitFor(devCode);
    expect(find.text('Phone Number Verification'), findsOneWidget);
    await shot(t, '03-verification-code');
    final code = RegExp(r'(\d{4})$').firstMatch(t.widget<Text>(devCode).data!)!.group(1)!;
    await t.enterText(find.byKey(const Key('codeInputField')), code); // auto-submits on the 4th digit

    // ---------------------------------------------------------------- Step 1: Personal details
    await t.waitFor(find.byKey(const Key('fullNameField')));
    await t.enterText(find.byKey(const Key('fullNameField')), 'Anu Suresh');
    await t.enterText(find.byKey(const Key('fatherNameField')), 'Suresh Shetty');
    await t.enterText(find.byKey(const Key('motherNameField')), 'Lakshmi');
    await t.tapVisible(find.byKey(const Key('dateOfBirthField')));
    await t.tapVisible(find.text('OK')); // picker opens 12 years ago
    expect(find.byKey(const Key('ageText')), findsOneWidget);
    await t.tapVisible(find.byKey(const Key('choice-FEMALE')));
    await shot(t, '04-personal-details');
    await t.next();

    // ---------------------------------------------------------------- Step 2: Current Status → Class Studying
    await t.waitFor(find.byKey(const Key('choice-STUDENT')));
    expect(find.byKey(const Key('classStudyingField')), findsOneWidget, reason: 'Student is the default');

    await t.tapVisible(find.byKey(const Key('choice-WORKING')));
    expect(find.byKey(const Key('classStudyingField')), findsNothing, reason: 'Working hides Class Studying');
    expect(find.byKey(const Key('highestEducationField')), findsOneWidget);
    await shot(t, '06-current-status-working');

    await t.tapVisible(find.byKey(const Key('choice-UNEMPLOYED')));
    expect(find.byKey(const Key('classStudyingField')), findsNothing, reason: 'Unemployed hides Class Studying');

    await t.tapVisible(find.byKey(const Key('choice-STUDENT')));
    expect(find.byKey(const Key('classStudyingField')), findsOneWidget);
    await t.selectFromDropdown(const Key('classStudyingField'), 'PUC 1');
    await shot(t, '05-current-status-student');
    await t.next();

    // ---------------------------------------------------------------- Step 3: Temple & Organisation
    await t.waitFor(find.byKey(const Key('templeField')));
    await t.selectFromDropdown(const Key('templeField'), 'Temple 01 (Placeholder - update name)');
    await t.selectFromDropdown(const Key('organisationField'), 'DK District');
    await shot(t, '07-temple-organisation');
    await t.next();

    // ---------------------------------------------------------------- Step 4: Address with PIN lookup
    await t.waitFor(find.byKey(const Key('permanentAddress.addressLine1')));
    await t.enterText(find.byKey(const Key('permanentAddress.addressLine1')), 'House 12, Temple Road');
    await t.enterText(find.byKey(const Key('permanentAddress.pinCode')), '574201');
    await t.waitFor(find.byKey(const Key('permanentAddress.talukId')), timeout: const Duration(seconds: 30));
    expect(find.text('Dakshina Kannada'), findsWidgets);
    expect(find.text('Karnataka'), findsWidgets);
    expect(find.text('India'), findsWidgets);
    expect(find.text('Puttur'), findsWidgets, reason: 'taluk suggested from the PIN data');
    await t.enterText(find.byKey(const Key('permanentAddress.cityVillageName')), 'Puttur');
    await shot(t, '08-address-pin-lookup');
    await t.tapVisible(find.byKey(const Key('sameAsPermanentCheckbox')));
    expect(find.text('Current Address'), findsNothing);
    await t.next();

    // ---------------------------------------------------------------- Step 5: Disability + consent
    await t.waitFor(find.byKey(const Key('isDisabledField')));
    expect(find.byKey(const Key('disabilityTypesField')), findsNothing, reason: 'Disabled = No hides the type');
    await t.tapVisible(find.text('Yes'));
    expect(find.byKey(const Key('disabilityTypesField')), findsOneWidget, reason: 'Disabled = Yes shows the type');
    await shot(t, '09-disability-yes');
    await t.tapVisible(find.text('No'));
    expect(find.byKey(const Key('disabilityTypesField')), findsNothing);

    await t.tapVisible(find.text('I have read and agree to the Privacy Policy.'));
    await t.tapVisible(find.textContaining('I am the parent or guardian'));
    await shot(t, '10-disability-consent');
    await t.tapVisible(find.byKey(const Key('nextButton'))); // Complete Registration

    // ---------------------------------------------------------------- Registration complete
    await t.waitFor(find.byKey(const Key('registrationSuccessTitle')), timeout: const Duration(seconds: 30));
    final id = t.widget<SelectableText>(find.byKey(const Key('registrationIdText'))).data!;
    expect(id, matches(RegExp(r'^PVS-01-\d{4}$')));
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('Your basic profile has been created.'), findsOneWidget);
    await shot(t, '11-registration-complete');
    await t.tapVisible(find.byKey(const Key('continueToProfileButton')));

    // ---------------------------------------------------------------- Home with profile completion
    await t.waitFor(find.byKey(const Key('overallPercent')));
    expect(find.text('Hello, Anu'), findsOneWidget);
    expect(find.byKey(const Key('section-basic')), findsOneWidget);
    expect(find.text('Complete'), findsWidgets);
    await shot(t, '12-home-dashboard');

    // ---------------------------------------------------------------- My Profile
    await t.tapVisible(find.byKey(const Key('myProfileLink')));
    await t.waitFor(find.text('Personal Information'));
    expect(find.text('PUC 1'), findsOneWidget);
    expect(find.textContaining(id), findsOneWidget);
    await shot(t, '13-my-profile');
  });
}

extension on WidgetTester {
  /// Pumps until [finder] matches (network calls do not keep pumpAndSettle busy).
  Future<void> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 20)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  /// Hides the keyboard, scrolls [finder] to the middle of the screen (clear of the app bar) and taps it.
  Future<void> tapVisible(Finder finder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await pumpAndSettle();
    await Scrollable.ensureVisible(element(finder.first), alignment: 0.5);
    await pumpAndSettle();
    await tap(finder.first);
    await pumpAndSettle();
  }

  Future<void> next() => tapVisible(find.byKey(const Key('nextButton')));

  Future<void> selectFromDropdown(Key fieldKey, String option) async {
    final field = find.descendant(of: find.byKey(fieldKey), matching: find.byType(DropdownButtonFormField<int>));
    await waitFor(field);
    await tapVisible(field);
    await tap(find.text(option).last);
    await pumpAndSettle();
  }
}
