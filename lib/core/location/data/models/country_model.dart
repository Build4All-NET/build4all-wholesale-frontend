class CountryModel {
  final int id;
  final String iso2Code;
  final String iso3Code;
  final String name;
  final bool active;

  const CountryModel({
    required this.id,
    required this.iso2Code,
    required this.iso3Code,
    required this.name,
    required this.active,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      iso2Code: json['iso2Code']?.toString().toUpperCase() ?? '',
      iso3Code: json['iso3Code']?.toString().toUpperCase() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] == true || json['active']?.toString() == 'true',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CountryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
