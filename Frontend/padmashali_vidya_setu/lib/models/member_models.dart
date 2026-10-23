import 'master_data_item.dart';

class MemberSummary {
  const MemberSummary({
    required this.registrationId,
    required this.fullName,
    required this.age,
    required this.templeName,
    required this.memberStatusName,
    required this.profileCompletionPercent,
  });

  final String registrationId;
  final String fullName;
  final int age;
  final String templeName;
  final String memberStatusName;
  final int profileCompletionPercent;

  factory MemberSummary.fromJson(Object? json) {
    final m = json! as Json;
    return MemberSummary(
      registrationId: m['registrationId']! as String,
      fullName: m['fullName']! as String,
      age: m['age']! as int,
      templeName: m['templeName']! as String,
      memberStatusName: m['memberStatusName']! as String,
      profileCompletionPercent: m['profileCompletionPercent']! as int,
    );
  }
}

class MyAccount {
  const MyAccount({required this.maskedMobileNumber, required this.members, required this.maxMembersPerAccount});

  final String maskedMobileNumber;
  final List<MemberSummary> members;
  final int maxMembersPerAccount;

  bool get canAddMember => members.length < maxMembersPerAccount;

  factory MyAccount.fromJson(Object? json) {
    final m = json! as Json;
    return MyAccount(
      maskedMobileNumber: m['maskedMobileNumber']! as String,
      members: (m['members']! as List<Object?>).map(MemberSummary.fromJson).toList(growable: false),
      maxMembersPerAccount: m['maxMembersPerAccount']! as int,
    );
  }
}

class RegistrationResult {
  const RegistrationResult({required this.registrationId, required this.fullName, required this.templeName});

  final String registrationId;
  final String fullName;
  final String templeName;

  factory RegistrationResult.fromJson(Object? json) {
    final m = json! as Json;
    return RegistrationResult(
      registrationId: m['registrationId']! as String,
      fullName: m['fullName']! as String,
      templeName: m['templeName']! as String,
    );
  }
}

enum SectionStatus { complete, inProgress, notStarted, notApplicable }

class ProfileSection {
  const ProfileSection({
    required this.key,
    required this.title,
    required this.status,
    required this.percent,
    required this.isAvailable,
  });

  final String key;

  /// Display title from the server (localizable server-side later).
  final String title;
  final SectionStatus status;
  final int percent;

  /// False while the module is still being built ("Coming soon").
  final bool isAvailable;

  factory ProfileSection.fromJson(Object? json) {
    final m = json! as Json;
    return ProfileSection(
      key: m['key']! as String,
      title: m['title']! as String,
      status: switch (m['status']) {
        'Complete' => SectionStatus.complete,
        'InProgress' => SectionStatus.inProgress,
        'NotApplicable' => SectionStatus.notApplicable,
        _ => SectionStatus.notStarted,
      },
      percent: m['percent']! as int,
      isAvailable: m['isAvailable']! as bool,
    );
  }
}

class MemberDashboard {
  const MemberDashboard({
    required this.registrationId,
    required this.fullName,
    required this.age,
    required this.memberStatusCode,
    required this.overallPercent,
    required this.sections,
  });

  final String registrationId;
  final String fullName;
  final int age;
  final String memberStatusCode;
  final int overallPercent;
  final List<ProfileSection> sections;

  factory MemberDashboard.fromJson(Object? json) {
    final m = json! as Json;
    final completion = m['profileCompletion']! as Json;
    return MemberDashboard(
      registrationId: m['registrationId']! as String,
      fullName: m['fullName']! as String,
      age: m['age']! as int,
      memberStatusCode: m['memberStatusCode']! as String,
      overallPercent: completion['overallPercent']! as int,
      sections: (completion['sections']! as List<Object?>).map(ProfileSection.fromJson).toList(growable: false),
    );
  }
}

class LookupRef {
  const LookupRef({required this.id, required this.name});
  final int id;
  final String name;

  static LookupRef? fromJson(Object? json) {
    if (json == null) return null;
    final m = json as Json;
    return LookupRef(id: m['id']! as int, name: m['name']! as String);
  }
}

class AddressView {
  const AddressView({
    required this.addressType,
    required this.addressLine1,
    this.addressLine2,
    this.pinCode,
    required this.cityVillageName,
    this.taluk,
    this.district,
    required this.state,
    required this.country,
  });

  final String addressType;
  final String addressLine1;
  final String? addressLine2;

  /// PIN code in India; outside India the postal code, if any.
  final String? pinCode;
  final String cityVillageName;

  /// Null for an address outside India (also [district]).
  final String? taluk;
  final String? district;
  final String state;
  final String country;

  bool get isPermanent => addressType == 'Permanent';

  factory AddressView.fromJson(Object? json) {
    final m = json! as Json;
    return AddressView(
      addressType: m['addressType']! as String,
      addressLine1: m['addressLine1']! as String,
      addressLine2: m['addressLine2'] as String?,
      pinCode: m['pinCode'] as String?,
      cityVillageName: m['cityVillageName']! as String,
      taluk: LookupRef.fromJson(m['taluk'])?.name,
      district: LookupRef.fromJson(m['district'])?.name,
      state: LookupRef.fromJson(m['state'])!.name,
      country: LookupRef.fromJson(m['country'])!.name,
    );
  }
}

class MemberProfile {
  const MemberProfile({
    required this.registrationId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.temple,
    required this.memberStatus,
    required this.memberStatusCode,
    this.schoolClass,
    this.highestEducation,
    required this.organisation,
    required this.addresses,
    required this.isDisabled,
    required this.disabilityTypes,
    required this.registrationCompletedDate,
    this.mobileNumber,
  });

  final String registrationId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final DateTime dateOfBirth;
  final int age;
  final String gender;
  final String temple;
  final String memberStatus;
  final String memberStatusCode;
  final String? schoolClass;
  final String? highestEducation;
  final String organisation;
  final List<AddressView> addresses;
  final bool isDisabled;
  final List<String> disabilityTypes;
  final DateTime registrationCompletedDate;

  /// The member's own verified mobile number (E.164), if one was added at registration.
  final String? mobileNumber;

  bool get isStudent => memberStatusCode == MasterCodes.statusStudent;

  factory MemberProfile.fromJson(Object? json) {
    final m = json! as Json;
    return MemberProfile(
      registrationId: m['registrationId']! as String,
      fullName: m['fullName']! as String,
      fatherName: m['fatherName']! as String,
      motherName: m['motherName']! as String,
      dateOfBirth: DateTime.parse(m['dateOfBirth']! as String),
      age: m['age']! as int,
      gender: LookupRef.fromJson(m['gender'])!.name,
      temple: LookupRef.fromJson(m['temple'])!.name,
      memberStatus: LookupRef.fromJson(m['memberStatus'])!.name,
      memberStatusCode: m['memberStatusCode']! as String,
      schoolClass: LookupRef.fromJson(m['class'])?.name,
      highestEducation: LookupRef.fromJson(m['highestEducationLevel'])?.name,
      organisation: LookupRef.fromJson(m['organisation'])!.name,
      addresses: (m['addresses']! as List<Object?>).map(AddressView.fromJson).toList(growable: false),
      isDisabled: m['isDisabled']! as bool,
      disabilityTypes: (m['disabilityTypes']! as List<Object?>)
          .map((d) => LookupRef.fromJson(d)!.name)
          .toList(growable: false),
      registrationCompletedDate: DateTime.parse(m['registrationCompletedDate']! as String),
      mobileNumber: m['mobileNumber'] as String?,
    );
  }
}
