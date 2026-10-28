import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/utils/phone_countries.dart';
import 'package:padmashali_vidya_setu/models/location_models.dart';
import 'package:padmashali_vidya_setu/models/master_data_item.dart';
import 'package:padmashali_vidya_setu/models/member_models.dart';
import 'package:padmashali_vidya_setu/models/registration_draft.dart';
import 'package:padmashali_vidya_setu/providers/session.dart';
import 'package:padmashali_vidya_setu/routing/app_router.dart';
import 'package:padmashali_vidya_setu/routing/routes.dart';
import 'package:padmashali_vidya_setu/utils/age.dart';
import 'package:padmashali_vidya_setu/utils/validators.dart';

const student = MasterDataItem(id: 1, name: 'Student', code: 'STUDENT');
const working = MasterDataItem(id: 2, name: 'Working', code: 'WORKING');
const unemployed = MasterDataItem(id: 3, name: 'Unemployed', code: 'UNEMPLOYED');

void main() {
  group('Validators', () {
    test('mobile accepts 10-digit Indian numbers only', () {
      expect(Validators.mobile('9876543210'), isNull);
      expect(Validators.mobile('6000000000'), isNull);
      expect(Validators.mobile(''), ValidationIssue.required);
      expect(Validators.mobile('5876543210'), ValidationIssue.phoneInvalid);
      expect(Validators.mobile('98765'), ValidationIssue.phoneInvalid);
    });

    test('mobile outside India: E.164 length with the country code; sent as +CC number', () {
      expect(Validators.mobile('501234567', countryCode: '971'), isNull);
      expect(Validators.mobile('07911123456', countryCode: '44'), isNull); // trunk 0 is dropped
      expect(Validators.mobile('1234', countryCode: '971'), ValidationIssue.phoneInvalidInternational);
      expect(Validators.mobile('1234567890123', countryCode: '971'), ValidationIssue.phoneInvalidInternational);
      expect(Validators.mobile('', countryCode: '971'), ValidationIssue.required);
      expect(DialCodes.apiNumber('971', '501234567'), '+971501234567');
      expect(DialCodes.apiNumber('44', '07911123456'), '+447911123456');
      expect(DialCodes.apiNumber('91', '9876543210'), '9876543210'); // Indian numbers unchanged
    });

    test('PIN code must be exactly 6 digits and not start with 0', () {
      expect(Validators.pinCode('574201'), isNull);
      expect(Validators.pinCode('57420'), ValidationIssue.pinInvalid);
      expect(Validators.pinCode('074201'), ValidationIssue.pinInvalid);
      expect(Validators.pinCode('5742011'), ValidationIssue.pinInvalid);
      expect(Validators.pinCode(''), ValidationIssue.required);
      expect(Validators.postalCode(''), isNull);
      expect(Validators.postalCode('SW1A 1AA'), isNull);
      expect(Validators.postalCode('#12'), ValidationIssue.postalCodeInvalid);
    });

    test('names accept Kannada and English, reject digits and symbols', () {
      expect(Validators.personName('Anu Suresh'), isNull);
      expect(Validators.personName("D'Souza-Rao"), isNull);
      expect(Validators.personName('ಅನು ಸುರೇಶ್'), isNull);
      expect(Validators.personName('A'), ValidationIssue.nameTooShort);
      expect(Validators.personName('Anu123'), ValidationIssue.nameInvalid);
      expect(Validators.personName('<b>'), ValidationIssue.nameInvalid);
      expect(Validators.personName('   '), ValidationIssue.required);
    });
  });

  group('Age', () {
    test('counts completed years', () {
      expect(ageOn(DateTime(2010, 8, 15), DateTime(2026, 8, 14)), 15);
      expect(ageOn(DateTime(2010, 8, 15), DateTime(2026, 8, 15)), 16);
    });

    test('29 February birthdays count from 28 February in non-leap years (same as API)', () {
      expect(ageOn(DateTime(2012, 2, 29), DateTime(2026, 2, 27)), 13);
      expect(ageOn(DateTime(2012, 2, 29), DateTime(2026, 2, 28)), 14);
    });
  });

  group('RegistrationDraft conditional rules', () {
    test('Rule 1-2: no status yet behaves as Student (default) and shows Class Studying', () {
      expect(RegistrationDraft().showsClassStudying, isTrue);
    });

    test('Rule 3-4: Working / Unemployed hide Class Studying and send Highest Education instead', () {
      for (final status in [working, unemployed]) {
        final d = RegistrationDraft()
          ..selectStatus(student)
          ..classId = 13
          ..selectStatus(status)
          ..highestEducationLevelId = 6;
        expect(d.showsClassStudying, isFalse);
        final json = d.toJson(otherDisabilityTypeId: 8);
        expect(json['classId'], isNull);
        expect(json['highestEducationLevelId'], 6);
      }
    });

    test('switching back to Student clears Highest Education', () {
      final d = RegistrationDraft()
        ..selectStatus(working)
        ..highestEducationLevelId = 6
        ..selectStatus(student)
        ..classId = 13;
      final json = d.toJson(otherDisabilityTypeId: 8);
      expect(json['classId'], 13);
      expect(json['highestEducationLevelId'], isNull);
    });

    test('Rule 5: Disabled = No sends no disability types', () {
      final d = RegistrationDraft()
        ..setDisabled(true)
        ..disabilityTypeIds.addAll([2, 8])
        ..otherDisabilityDescription = 'Low vision'
        ..setDisabled(false);
      final json = d.toJson(otherDisabilityTypeId: 8);
      expect(json['isDisabled'], isFalse);
      expect(json['disabilityTypeIds'], isEmpty);
      expect(json['otherDisabilityDescription'], isNull);
    });

    test('Rule 6: Disabled = Yes with Other sends the description', () {
      final d = RegistrationDraft()
        ..setDisabled(true)
        ..disabilityTypeIds.add(8)
        ..otherDisabilityDescription = '  Low   vision ';
      final json = d.toJson(otherDisabilityTypeId: 8);
      expect(json['disabilityTypeIds'], [8]);
      expect(json['otherDisabilityDescription'], 'Low vision');
    });

    test('Rule 7: current address is omitted when same as permanent', () {
      final d = RegistrationDraft()..currentSameAsPermanent = true;
      expect(d.toJson(otherDisabilityTypeId: null)['currentAddress'], isNull);
      d.currentSameAsPermanent = false;
      expect(d.toJson(otherDisabilityTypeId: null)['currentAddress'], isA<Map<String, Object?>>());
    });

    test('guardian consent is needed only under 18', () {
      final now = today();
      final d = RegistrationDraft()..dateOfBirth = DateTime(now.year - 10, now.month, now.day);
      expect(d.needsGuardianConsent, isTrue);
      d.dateOfBirth = DateTime(now.year - 25, now.month, now.day);
      expect(d.needsGuardianConsent, isFalse);
    });

    test('PIN lookup fills district/state/country and suggests taluk and single locality', () {
      final a = AddressDraft()
        ..applyLookup(
          const PinLookupResult(
            pinCode: '574201',
            country: MasterDataItem(id: 1, name: 'India', code: 'IN'),
            state: MasterDataItem(id: 11, name: 'Karnataka', code: 'IN-KA'),
            district: MasterDataItem(id: 11, name: 'Dakshina Kannada', code: 'KA-DK'),
            localities: [Locality(cityId: 7, name: 'Puttur', talukId: 3)],
            taluks: [MasterDataItem(id: 3, name: 'Puttur', code: 'KA-DK-PUTTUR')],
            suggestedTalukId: 3,
          ),
        );
      expect(a.district!.name, 'Dakshina Kannada');
      expect(a.state!.name, 'Karnataka');
      expect(a.country!.name, 'India');
      expect(a.talukId, 3);
      expect(a.cityVillageName, 'Puttur');
      expect(a.toJson()['cityId'], 7);
    });

    test('a copied Indian address re-selects its place and taluk after the PIN lookup', () {
      const source = AddressView(
        addressType: 'Permanent',
        addressLine1: '12, Car Street',
        pinCode: '574201',
        cityVillageName: 'Bolwar',
        state: 'Karnataka',
        country: 'India',
        talukId: 1,
        stateId: 11,
        countryId: 1,
      );
      final a = AddressDraft()
        ..pinCode = '575001'
        ..localities = const [Locality(cityId: 9, name: 'Old')]
        ..copyFrom(source, const MasterDataItem(id: 1, name: 'India', code: 'IN'));
      expect(a.localities, isEmpty); // the old lookup is gone, so the form looks the PIN up again
      expect(a.pinCode, '574201');
      a.applyLookup(
        const PinLookupResult(
          pinCode: '574201',
          country: MasterDataItem(id: 1, name: 'India', code: 'IN'),
          state: MasterDataItem(id: 11, name: 'Karnataka', code: 'IN-KA'),
          district: MasterDataItem(id: 11, name: 'Dakshina Kannada', code: 'KA-DK'),
          localities: [
            Locality(cityId: 7, name: 'Puttur', talukId: 3),
            Locality(cityId: 8, name: 'BOLWAR', talukId: 3),
          ],
          taluks: [],
          suggestedTalukId: 3,
        ),
      );
      expect(a.toJson()['cityId'], 8);
      expect(a.talukId, 1); // the member's own taluk, not the suggestion
    });

    test('a copied place the PIN no longer lists is typed in', () {
      final a = AddressDraft()
        ..preferredCityName = 'Kabaka'
        ..applyLookup(
          const PinLookupResult(
            pinCode: '574201',
            country: MasterDataItem(id: 1, name: 'India', code: 'IN'),
            state: MasterDataItem(id: 11, name: 'Karnataka', code: 'IN-KA'),
            district: MasterDataItem(id: 11, name: 'Dakshina Kannada', code: 'KA-DK'),
            localities: [
              Locality(cityId: 7, name: 'Puttur'),
              Locality(cityId: 8, name: 'Bolwar'),
            ],
            taluks: [],
          ),
        );
      expect(a.cityNotListed, isTrue);
      expect(a.toJson()['cityVillageName'], 'Kabaka');
      expect(a.toJson()['cityId'], isNull);
    });

    test('a copied address abroad keeps every typed field', () {
      const source = AddressView(
        addressType: 'Permanent',
        addressLine1: '5 Palm Street',
        pinCode: '94016',
        cityVillageName: 'San Francisco',
        state: 'California',
        country: 'United States',
        stateId: 40,
        countryId: 8,
      );
      final a = AddressDraft()..copyFrom(source, const MasterDataItem(id: 8, name: 'United States', code: 'US'));
      expect(a.isIndia, isFalse);
      expect(a.toJson(), containsPair('cityVillageName', 'San Francisco'));
      expect(a.toJson(), containsPair('stateId', 40));
      expect(a.toJson(), containsPair('countryId', 8));
      expect(a.toJson(), containsPair('pinCode', '94016'));
    });

    test('"place not listed" sends the typed name without a city id', () {
      final a = AddressDraft()
        ..localities = const [Locality(cityId: 7, name: 'Puttur')]
        ..selectLocality(const Locality(cityId: 7, name: 'Puttur'))
        ..selectPlaceNotListed()
        ..cityVillageName = 'Kabaka';
      expect(a.toJson()['cityId'], isNull);
      expect(a.toJson()['cityVillageName'], 'Kabaka');
    });
  });

  group('Router redirects', () {
    const account = MyAccount(maskedMobileNumber: '+91******3210', members: [], maxMembersPerAccount: 10);
    const member = MemberSummary(
      registrationId: 'PVS-01-0001',
      fullName: 'Anu',
      age: 12,
      templeName: 'T',
      memberStatusName: 'Student',
      profileCompletionPercent: 12,
    );
    final withMember = MyAccount(maskedMobileNumber: '+91******3210', members: [member], maxMembersPerAccount: 10);

    test('unknown session shows splash', () {
      expect(redirectFor(const SessionState(status: SessionStatus.unknown), Routes.home), Routes.splash);
    });

    test('signed out users only reach public pages', () {
      const s = SessionState(status: SessionStatus.signedOut);
      expect(redirectFor(s, Routes.home), Routes.welcome);
      expect(redirectFor(s, Routes.register), Routes.welcome);
      expect(redirectFor(s, Routes.phone), isNull);
    });

    test('signed in without members must register first', () {
      const s = SessionState(status: SessionStatus.signedIn, account: account);
      expect(redirectFor(s, Routes.verify), Routes.register);
      expect(redirectFor(s, Routes.home), Routes.register);
      expect(redirectFor(s, Routes.register), isNull);
      // Privacy / Terms links in the registration form.
      expect(redirectFor(s, Routes.privacy), isNull);
      expect(redirectFor(s, Routes.terms), isNull);
    });

    test('signed in with members lands on home but may add family members', () {
      final s = SessionState(status: SessionStatus.signedIn, account: withMember);
      expect(redirectFor(s, Routes.verify), Routes.home);
      expect(redirectFor(s, Routes.splash), Routes.home);
      expect(redirectFor(s, Routes.register), isNull);
      expect(redirectFor(s, Routes.registrationComplete), isNull);
    });

    test('signed in with members can open Contact, Privacy Policy and Terms from the menu', () {
      final s = SessionState(status: SessionStatus.signedIn, account: withMember);
      expect(redirectFor(s, Routes.contact), isNull);
      expect(redirectFor(s, Routes.privacy), isNull);
      expect(redirectFor(s, Routes.terms), isNull);
      expect(redirectFor(s, Routes.welcome), Routes.home);
    });

    test('signed out users can open Contact, Privacy Policy and Terms', () {
      const s = SessionState(status: SessionStatus.signedOut);
      expect(redirectFor(s, Routes.contact), isNull);
      expect(redirectFor(s, Routes.privacy), isNull);
      expect(redirectFor(s, Routes.terms), isNull);
    });
  });

  test('UI text never uses the term "OTP"', () {
    final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, Object?>;
    final texts = arb.entries.where((e) => !e.key.startsWith('@')).map((e) => '${e.value}');
    for (final text in texts) {
      expect(RegExp(r'\bOTP\b', caseSensitive: false).hasMatch(text), isFalse, reason: text);
    }
    expect(arb['codeFieldLabel'], contains('4-digit Phone Number Verification Code'));
  });
}
