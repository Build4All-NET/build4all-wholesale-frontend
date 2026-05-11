import 'package:equatable/equatable.dart';

class TaxRuleEntity extends Equatable {
  final String id;
  final String ruleName;
  final double rate;

  final String countryId;
  final String countryName;
  final String? countryIso2Code;
  final String? countryIso3Code;

  final String? regionId;
  final String? regionName;
  final String? regionCode;

  final bool appliesToShipping;
  final bool active;
  final String? status;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TaxRuleEntity({
    required this.id,
    required this.ruleName,
    required this.rate,
    required this.countryId,
    required this.countryName,
    this.countryIso2Code,
    this.countryIso3Code,
    this.regionId,
    this.regionName,
    this.regionCode,
    required this.appliesToShipping,
    required this.active,
    this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get rateLabel => '${_cleanNumber(rate)}%';

  String get statusLabel {
    final normalized = status?.trim().toUpperCase();

    if (normalized == 'ACTIVE') return 'Active';
    if (normalized == 'INACTIVE') return 'Inactive';

    return active ? 'Active' : 'Inactive';
  }

  String get locationLabel {
    final country = countryName.trim();
    final region = regionName?.trim();

    if (region != null && region.isNotEmpty) {
      return '$country • $region';
    }

    return country;
  }

  String get scopeLabel {
    final region = regionName?.trim();

    if (region != null && region.isNotEmpty) {
      return 'Region rule';
    }

    return 'Country rule';
  }

  String get shippingTaxLabel {
    return appliesToShipping ? 'Applies to shipping' : 'Items only';
  }

  TaxRuleEntity copyWith({
    String? id,
    String? ruleName,
    double? rate,
    String? countryId,
    String? countryName,
    String? countryIso2Code,
    String? countryIso3Code,
    String? regionId,
    String? regionName,
    String? regionCode,
    bool? appliesToShipping,
    bool? active,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxRuleEntity(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      rate: rate ?? this.rate,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      countryIso2Code: countryIso2Code ?? this.countryIso2Code,
      countryIso3Code: countryIso3Code ?? this.countryIso3Code,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      regionCode: regionCode ?? this.regionCode,
      appliesToShipping: appliesToShipping ?? this.appliesToShipping,
      active: active ?? this.active,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [
        id,
        ruleName,
        rate,
        countryId,
        countryName,
        countryIso2Code,
        countryIso3Code,
        regionId,
        regionName,
        regionCode,
        appliesToShipping,
        active,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}