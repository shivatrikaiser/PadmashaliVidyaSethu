typedef Json = Map<String, Object?>;

/// One entry of a configurable list (temple, class, gender, ...).
/// [code] is a stable identifier used for the few rules that depend on a specific value;
/// [name] is display text that administrators may change.
class MasterDataItem {
  const MasterDataItem({required this.id, required this.name, required this.code});

  final int id;
  final String name;
  final String code;

  factory MasterDataItem.fromJson(Object? json) {
    final m = json! as Json;
    return MasterDataItem(id: m['id']! as int, name: m['name']! as String, code: (m['code'] as String?) ?? '');
  }

  static List<MasterDataItem> listFromJson(Object? json) =>
      (json! as List<Object?>).map(MasterDataItem.fromJson).toList(growable: false);

  @override
  bool operator ==(Object other) => other is MasterDataItem && other.id == id && other.code == code;

  @override
  int get hashCode => Object.hash(id, code);

  @override
  String toString() => 'MasterDataItem($id, $code, $name)';
}

/// Codes the app relies on. Everything else about master data comes from the server.
abstract final class MasterCodes {
  static const statusStudent = 'STUDENT';

  /// ISO code of India: Indian addresses use the PIN-code flow (District, Taluk); others are typed.
  static const countryIndia = 'IN';
  static const disabilityOther = other;

  /// Every selectable list has an "Other" row; choosing it asks for the value as free text.
  static const other = 'OTHER';
}

/// Keys for `/api/v1/master-data/{type}`.
abstract final class MasterDataTypes {
  static const temples = 'temples';
  static const organisations = 'organisations';
  static const genders = 'genders';
  static const memberStatuses = 'member-statuses';
  static const classes = 'classes';
  static const educationLevels = 'education-levels';
  static const disabilityTypes = 'disability-types';
  static const countries = 'countries';
}
