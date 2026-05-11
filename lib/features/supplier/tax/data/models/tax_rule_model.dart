import '../../domain/entities/tax_rule_entity.dart';

class TaxRuleModel extends TaxRuleEntity {
  const TaxRuleModel({
    required super.id,
    required super.ruleName,
    required super.rate,
    required super.countryId,
    required super.countryName,
    super.countryIso2Code,
    super.countryIso3Code,
    super.regionId,
    super.regionName,
    super.regionCode,
    required super.appliesToShipping,
    required super.active,
    super.status,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaxRuleModel.fromEntity(TaxRuleEntity entity) {
    return TaxRuleModel(
      id: entity.id,
      ruleName: entity.ruleName,
      rate: entity.rate,
      countryId: entity.countryId,
      countryName: entity.countryName,
      countryIso2Code: entity.countryIso2Code,
      countryIso3Code: entity.countryIso3Code,
      regionId: entity.regionId,
      regionName: entity.regionName,
      regionCode: entity.regionCode,
      appliesToShipping: entity.appliesToShipping,
      active: entity.active,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory TaxRuleModel.fromJson(Map<String, dynamic> json) {
    return TaxRuleModel(
      id: json['id']?.toString() ?? '',
      ruleName: _cleanText(json['ruleName']) ?? '',
      rate: _doubleFromJson(json['rate']) ?? 0,
      countryId: json['countryId']?.toString() ?? '',
      countryName: _cleanText(json['countryName']) ?? '',
      countryIso2Code: _cleanText(json['countryIso2Code']),
      countryIso3Code: _cleanText(json['countryIso3Code']),
      regionId: json['regionId']?.toString(),
      regionName: _cleanText(json['regionName']),
      regionCode: _cleanText(json['regionCode']),
      appliesToShipping: json['appliesToShipping'] == true,
      active: json['active'] != false,
      status: _cleanText(json['status']),
      notes: _cleanText(json['notes']),
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'ruleName': ruleName.trim(),
      'rate': rate,
      'countryId': int.tryParse(countryId),
      'regionId': regionId == null ? null : int.tryParse(regionId!),
      'appliesToShipping': appliesToShipping,
      'active': active,
      'notes': notes == null || notes!.trim().isEmpty ? null : notes!.trim(),
    };
  }

  TaxRuleEntity toEntity() {
    return TaxRuleEntity(
      id: id,
      ruleName: ruleName,
      rate: rate,
      countryId: countryId,
      countryName: countryName,
      countryIso2Code: countryIso2Code,
      countryIso3Code: countryIso3Code,
      regionId: regionId,
      regionName: regionName,
      regionCode: regionCode,
      appliesToShipping: appliesToShipping,
      active: active,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _cleanText(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}