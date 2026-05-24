class RegionModel {
  final int id;
  final String code;
  final String name;
  final bool active;
  final int countryId;
  final String countryIso2Code;
  final String countryIso3Code;
  final String countryName;

  const RegionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.active,
    required this.countryId,
    required this.countryIso2Code,
    required this.countryIso3Code,
    required this.countryName,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] == true || json['active']?.toString() == 'true',
      countryId: int.tryParse(json['countryId']?.toString() ?? '') ?? 0,
      countryIso2Code: json['countryIso2Code']?.toString().toUpperCase() ?? '',
      countryIso3Code: json['countryIso3Code']?.toString().toUpperCase() ?? '',
      countryName: json['countryName']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RegionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
