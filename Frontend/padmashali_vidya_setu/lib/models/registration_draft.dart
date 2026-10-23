import '../utils/age.dart';
import '../utils/phone_countries.dart';
import '../utils/validators.dart';
import 'location_models.dart';
import 'master_data_item.dart';

/// Address being entered in the registration form.
class AddressDraft {
  String addressLine1 = '';
  String addressLine2 = '';
  String pinCode = '';
  String cityVillageName = '';

  /// The place chosen from the PIN lookup (a `PVS_Cities` row); null when typed by hand.
  int? cityId;

  /// "My place is not listed" - the member types the City / Village instead of choosing it.
  bool cityNotListed = false;

  MasterDataItem? country;
  MasterDataItem? state;
  MasterDataItem? district;

  /// Outside India: the State / Province is not in the country's list (or the list is empty) - the member types it.
  bool stateNotListed = false;
  String newStateName = '';

  int? talukId;
  bool talukNotListed = false;
  String newTalukName = '';

  /// Results of the last PIN lookup, used to populate the City/Village and Taluk choices.
  List<Locality> localities = const [];

  /// India (or not chosen yet): PIN code, City / Village, District and Taluk. Otherwise the address is typed.
  bool get isIndia => country == null || country!.code == MasterCodes.countryIndia;

  /// A different country starts the address again (except the street lines), since every other field depends on it.
  void selectCountry(MasterDataItem value) {
    if (value.id == country?.id) return;
    country = value;
    pinCode = '';
    cityVillageName = '';
    cityId = null;
    cityNotListed = false;
    localities = const [];
    state = null;
    stateNotListed = false;
    newStateName = '';
    district = null;
    talukId = null;
    talukNotListed = false;
    newTalukName = '';
  }

  void applyLookup(PinLookupResult result) {
    country = result.country;
    state = result.state;
    district = result.district;
    localities = result.localities;
    talukNotListed = false;
    talukId = result.suggestedTalukId;
    cityNotListed = false;
    if (localities.length == 1) {
      selectLocality(localities.single);
    } else if (!localities.any((l) => l.cityId == cityId)) {
      cityId = null;
      cityVillageName = '';
    }
  }

  void clearLookup() {
    localities = const [];
    cityId = null;
  }

  /// The member picked one of the places linked to the PIN code.
  void selectLocality(Locality locality) {
    cityNotListed = false;
    cityId = locality.cityId;
    cityVillageName = locality.name;
    if (locality.talukId != null && !talukNotListed) talukId = locality.talukId;
  }

  /// The member's place is not in the PIN code's list - they type it.
  void selectPlaceNotListed() {
    cityNotListed = true;
    cityId = null;
    cityVillageName = '';
  }

  /// True when the City / Village is chosen from the PIN code's places (otherwise it is typed).
  bool get choosesCityFromList => localities.isNotEmpty && !cityNotListed;

  Map<String, Object?> toJson() {
    if (!isIndia) {
      final postalCode = Validators.tidy(pinCode).toUpperCase();
      return {
        'addressLine1': Validators.tidy(addressLine1),
        'addressLine2': Validators.tidy(addressLine2).isEmpty ? null : Validators.tidy(addressLine2),
        'pinCode': postalCode.isEmpty ? null : postalCode,
        'cityVillageName': Validators.tidy(cityVillageName),
        'stateId': stateNotListed ? null : state?.id,
        'newStateName': stateNotListed ? Validators.tidy(newStateName) : null,
        'countryId': country?.id,
      };
    }
    final chosen = choosesCityFromList ? localities.where((l) => l.cityId == cityId).firstOrNull : null;
    return {
      'addressLine1': Validators.tidy(addressLine1),
      'addressLine2': Validators.tidy(addressLine2).isEmpty ? null : Validators.tidy(addressLine2),
      'pinCode': pinCode.trim(),
      'cityVillageName': chosen?.name ?? Validators.tidy(cityVillageName),
      'cityId': chosen?.cityId,
      'talukId': talukNotListed ? null : talukId,
      'newTalukName': talukNotListed ? Validators.tidy(newTalukName) : null,
      'districtId': district?.id,
      'stateId': state?.id,
      'countryId': country?.id,
    };
  }
}

/// Everything entered during registration. Holds the conditional rules in one place so the
/// UI and the request body always agree.
class RegistrationDraft {
  static const minimumAge = 5;
  static const guardianConsentBelowAge = 18;

  String fullName = '';
  String fatherName = '';
  String motherName = '';

  /// The member's own mobile number (10 digits, optional). Sent only when it was verified with a code:
  /// [verifiedMobileNumber] is the number that code proved, [mobileVerificationId] the verified challenge.
  String mobileNumber = '';
  String mobileCountryCode = DialCodes.india;
  String? verifiedMobileNumber;
  String? mobileVerificationId;

  String get mobileDigits => mobileNumber.replaceAll(RegExp(r'\D'), '');
  bool get hasMobileNumber => mobileDigits.isNotEmpty;

  /// What the API gets (and what a verification proves): 10 digits in India, +CCNNNN... elsewhere.
  String get apiMobileNumber => DialCodes.apiNumber(mobileCountryCode, mobileDigits);
  bool get mobileIsVerified =>
      hasMobileNumber && verifiedMobileNumber == apiMobileNumber && mobileVerificationId != null;

  /// The member's email address (optional), verified with its own code: [verifiedEmail] is the address that code
  /// proved, [emailVerificationId] the verified challenge.
  String email = '';
  String? verifiedEmail;
  String? emailVerificationId;

  String get emailTrimmed => email.trim().toLowerCase();
  bool get hasEmail => emailTrimmed.isNotEmpty;
  bool get emailIsVerified => hasEmail && verifiedEmail == emailTrimmed && emailVerificationId != null;

  DateTime? dateOfBirth;
  int? genderId;

  /// Rule 1: defaults to Student — set from master data when the status list loads.
  MasterDataItem? memberStatus;
  int? classId;
  int? highestEducationLevelId;
  String? highestEducationLevelCode;
  String highestEducationLevelOtherText = '';

  bool get highestEducationIsOther => !showsClassStudying && highestEducationLevelCode == MasterCodes.other;

  int? templeId;
  int? organisationId;

  final AddressDraft permanentAddress = AddressDraft();
  bool currentSameAsPermanent = false;
  AddressDraft currentAddress = AddressDraft();

  /// Rule 5/6: defaults to No.
  bool isDisabled = false;
  final Set<int> disabilityTypeIds = {};
  String otherDisabilityDescription = '';

  bool acceptPrivacyPolicy = false;
  bool guardianConsent = false;

  /// Rule 2-4: Class Studying only for students; Highest Education otherwise.
  bool get showsClassStudying => memberStatus == null || memberStatus!.code == MasterCodes.statusStudent;

  int? ageToday([DateTime? now]) => dateOfBirth == null ? null : ageOn(dateOfBirth!, now ?? today());

  bool get needsGuardianConsent {
    final age = ageToday();
    return age != null && age < guardianConsentBelowAge;
  }

  void selectStatus(MasterDataItem status) {
    memberStatus = status;
    // Keep only the field relevant to the new status (matches the backend rule).
    if (showsClassStudying) {
      highestEducationLevelId = null;
      highestEducationLevelCode = null;
      highestEducationLevelOtherText = '';
    } else {
      classId = null;
    }
  }

  void setDisabled(bool value) {
    isDisabled = value;
    if (!value) {
      disabilityTypeIds.clear();
      otherDisabilityDescription = '';
    }
  }

  Map<String, Object?> toJson({required int? otherDisabilityTypeId}) => {
    'fullName': Validators.tidy(fullName),
    'fatherName': Validators.tidy(fatherName),
    'motherName': Validators.tidy(motherName),
    'mobileNumber': hasMobileNumber ? apiMobileNumber : null,
    'mobileVerificationId': mobileIsVerified ? mobileVerificationId : null,
    'email': hasEmail ? emailTrimmed : null,
    'emailVerificationId': emailIsVerified ? emailVerificationId : null,
    'dateOfBirth': dateOfBirth == null ? null : isoDate(dateOfBirth!),
    'genderId': genderId,
    'templeId': templeId,
    'memberStatusId': memberStatus?.id,
    'classId': showsClassStudying ? classId : null,
    'highestEducationLevelId': showsClassStudying ? null : highestEducationLevelId,
    'highestEducationLevelOtherText': highestEducationIsOther ? Validators.tidy(highestEducationLevelOtherText) : null,
    'organisationId': organisationId,
    'permanentAddress': permanentAddress.toJson(),
    'currentAddressSameAsPermanent': currentSameAsPermanent,
    'currentAddress': currentSameAsPermanent ? null : currentAddress.toJson(),
    'isDisabled': isDisabled,
    'disabilityTypeIds': isDisabled ? disabilityTypeIds.toList() : <int>[],
    'otherDisabilityDescription':
        isDisabled && otherDisabilityTypeId != null && disabilityTypeIds.contains(otherDisabilityTypeId)
        ? Validators.tidy(otherDisabilityDescription)
        : null,
    'acceptPrivacyPolicy': acceptPrivacyPolicy,
    'guardianConsent': needsGuardianConsent && guardianConsent,
  };
}
