class ShippingCountryModel {
  final String id;
  final String iso2Code;
  final String iso3Code;
  final String name;
  final bool active;

  const ShippingCountryModel({
    required this.id,
    required this.iso2Code,
    required this.iso3Code,
    required this.name,
    required this.active,
  });

  factory ShippingCountryModel.fromJson(Map<String, dynamic> json) {
    return ShippingCountryModel(
      id: json['id']?.toString() ?? '',
      iso2Code: json['iso2Code']?.toString() ?? '',
      iso3Code: json['iso3Code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] != false,
    );
  }

  bool get isLebanon => iso2Code.toUpperCase() == 'LB';
}

class ShippingRegionModel {
  final String id;
  final String code;
  final String name;
  final bool active;

  final String countryId;
  final String countryIso2Code;
  final String countryIso3Code;
  final String countryName;

  const ShippingRegionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.active,
    required this.countryId,
    required this.countryIso2Code,
    required this.countryIso3Code,
    required this.countryName,
  });

  factory ShippingRegionModel.fromJson(Map<String, dynamic> json) {
    return ShippingRegionModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] != false,
      countryId: json['countryId']?.toString() ?? '',
      countryIso2Code: json['countryIso2Code']?.toString() ?? '',
      countryIso3Code: json['countryIso3Code']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
    );
  }
}