import 'master_data_item.dart';

DateTime _date(Object? value) => DateTime.parse(value! as String);

/// An event as one member sees it: only the groups that fit the member's age (on [ageAsOnDate]) and gender.
class MemberEvent {
  const MemberEvent({
    required this.eventId,
    required this.code,
    required this.title,
    this.description,
    this.venue,
    required this.eventDate,
    required this.ageAsOnDate,
    required this.registrationOpensDate,
    required this.registrationClosesDate,
    required this.maxGroupsPerMember,
    required this.age,
    required this.isRegistrationOpen,
    required this.groups,
    this.registration,
  });

  final int eventId;
  final String code;
  final String title;
  final String? description;
  final String? venue;
  final DateTime eventDate;
  final DateTime ageAsOnDate;
  final DateTime registrationOpensDate;
  final DateTime registrationClosesDate;
  final int maxGroupsPerMember;

  /// The member's age on [ageAsOnDate].
  final int age;

  /// Registering, changing groups and cancelling are possible today.
  final bool isRegistrationOpen;
  final List<EventGroupOption> groups;
  final MyEventRegistration? registration;

  bool get isRegistered => registration != null;

  /// Registration opens later (not yet closed).
  bool get opensLater => !isRegistrationOpen && DateTime.now().isBefore(registrationOpensDate);

  factory MemberEvent.fromJson(Object? json) {
    final m = json! as Json;
    return MemberEvent(
      eventId: m['eventId']! as int,
      code: m['code']! as String,
      title: m['title']! as String,
      description: m['description'] as String?,
      venue: m['venue'] as String?,
      eventDate: _date(m['eventDate']),
      ageAsOnDate: _date(m['ageAsOnDate']),
      registrationOpensDate: _date(m['registrationOpensDate']),
      registrationClosesDate: _date(m['registrationClosesDate']),
      maxGroupsPerMember: m['maxGroupsPerMember']! as int,
      age: m['age']! as int,
      isRegistrationOpen: m['isRegistrationOpen']! as bool,
      groups: (m['groups']! as List<Object?>).map(EventGroupOption.fromJson).toList(growable: false),
      registration: m['registration'] == null ? null : MyEventRegistration.fromJson(m['registration']),
    );
  }

  static List<MemberEvent> listFromJson(Object? json) =>
      (json! as List<Object?>).map(MemberEvent.fromJson).toList(growable: false);
}

class EventGroupOption {
  const EventGroupOption({
    required this.id,
    required this.name,
    required this.minAge,
    required this.maxAge,
    this.gender,
    required this.isFull,
  });

  final int id;
  final String name;
  final int minAge;
  final int maxAge;

  /// Null = open to everyone.
  final String? gender;
  final bool isFull;

  factory EventGroupOption.fromJson(Object? json) {
    final m = json! as Json;
    return EventGroupOption(
      id: m['id']! as int,
      name: m['name']! as String,
      minAge: m['minAge']! as int,
      maxAge: m['maxAge']! as int,
      gender: m['gender'] as String?,
      isFull: m['isFull']! as bool,
    );
  }
}

class MyEventRegistration {
  const MyEventRegistration({required this.registrationNumber, required this.groupIds, required this.groupNames});

  final String registrationNumber;
  final List<int> groupIds;
  final List<String> groupNames;

  factory MyEventRegistration.fromJson(Object? json) {
    final m = json! as Json;
    return MyEventRegistration(
      registrationNumber: m['registrationNumber']! as String,
      groupIds: (m['groupIds']! as List<Object?>).cast<int>(),
      groupNames: (m['groupNames']! as List<Object?>).cast<String>(),
    );
  }
}

/// Shown on the "Registered" screen.
class EventRegistrationResult {
  const EventRegistrationResult({
    required this.registrationNumber,
    required this.eventTitle,
    required this.eventDate,
    this.venue,
    required this.registrationId,
    required this.memberName,
    required this.groups,
  });

  final String registrationNumber;
  final String eventTitle;
  final DateTime eventDate;
  final String? venue;
  final String registrationId;
  final String memberName;
  final List<String> groups;

  factory EventRegistrationResult.fromJson(Object? json) {
    final m = json! as Json;
    return EventRegistrationResult(
      registrationNumber: m['registrationNumber']! as String,
      eventTitle: m['eventTitle']! as String,
      eventDate: _date(m['eventDate']),
      venue: m['venue'] as String?,
      registrationId: m['registrationId']! as String,
      memberName: m['memberName']! as String,
      groups: (m['groups']! as List<Object?>).cast<String>(),
    );
  }
}
