import '../utils/age.dart';
import '../utils/validators.dart';
import 'location_models.dart';
import 'master_data_item.dart';

/// Address being entered in the registration form.
class AddressDraft {
  String addressLine1 = '';
  String addressLine2 = '';
  String pinCode = '';
  String cityVillageName = '';
  int? cityId;

  MasterDataItem? country;
  MasterDataItem? state;
  MasterDataItem? district;

  int? talukId;
  bool talukNotListed = false;
  String newTalukName = '';

  /// Results of the last PIN lookup, used to populate the City/Village and Taluk choices.
  List<Locality> localities = const [];

  void applyLookup(PinLookupResult result) {
    country = result.country;
    state = result.state;
    district = result.district;
    localities = result.localities;
    talukNotListed = false;
    talukId = result.suggestedTalukId;
    if (localities.length == 1) {
      cityId = localities.single.cityId;
      cityVillageName = localities.single.name;
    } else if (!localities.any((l) => l.cityId == cityId)) {
      cityId = null;
    }
  }

  void clearLookup() {
    localities = const [];
    cityId = null;
  }

  Map<String, Object?> toJson() {
    // Only send cityId when the typed name still matches the chosen locality.
    final matchedCity = localities.where((l) => l.cityId == cityId && l.name == Validators.tidy(cityVillageName));
    return {
      'addressLine1': Validators.tidy(addressLine1),
      'addressLine2': Validators.tidy(addressLine2).isEmpty ? null : Validators.tidy(addressLine2),
      'pinCode': pinCode.trim(),
      'cityVillageName': Validators.tidy(cityVillageName),
      'cityId': matchedCity.isEmpty ? null : cityId,
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
  DateTime? dateOfBirth;
  int? genderId;

  /// Rule 1: defaults to Student — set from master data when the status list loads.
  MasterDataItem? memberStatus;
  int? classId;
  int? highestEducationLevelId;

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
    'dateOfBirth': dateOfBirth == null ? null : isoDate(dateOfBirth!),
    'genderId': genderId,
    'templeId': templeId,
    'memberStatusId': memberStatus?.id,
    'classId': showsClassStudying ? classId : null,
    'highestEducationLevelId': showsClassStudying ? null : highestEducationLevelId,
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
