import 'master_data_item.dart';

class Locality {
  const Locality({required this.cityId, required this.name, this.talukId});

  final int cityId;
  final String name;
  final int? talukId;

  factory Locality.fromJson(Object? json) {
    final m = json! as Json;
    return Locality(cityId: m['cityId']! as int, name: m['name']! as String, talukId: m['talukId'] as int?);
  }
}

class PinLookupResult {
  const PinLookupResult({
    required this.pinCode,
    required this.country,
    required this.state,
    required this.district,
    required this.localities,
    required this.taluks,
    this.suggestedTalukId,
  });

  final String pinCode;
  final MasterDataItem country;
  final MasterDataItem state;
  final MasterDataItem district;
  final List<Locality> localities;
  final List<MasterDataItem> taluks;
  final int? suggestedTalukId;

  factory PinLookupResult.fromJson(Object? json) {
    final m = json! as Json;
    return PinLookupResult(
      pinCode: m['pinCode']! as String,
      country: MasterDataItem.fromJson(m['country']),
      state: MasterDataItem.fromJson(m['state']),
      district: MasterDataItem.fromJson(m['district']),
      localities: (m['localities']! as List<Object?>).map(Locality.fromJson).toList(growable: false),
      taluks: MasterDataItem.listFromJson(m['taluks']),
      suggestedTalukId: m['suggestedTalukId'] as int?,
    );
  }
}
