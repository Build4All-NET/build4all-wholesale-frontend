import '../../domain/entities/tax_preview_entity.dart';

class TaxPreviewModel extends TaxPreviewEntity {
  const TaxPreviewModel({
    required super.taxApplied,
    super.taxRuleId,
    super.taxRuleName,
    required super.taxRate,
    required super.itemsSubtotal,
    required super.promotionDiscount,
    required super.taxableItemsAmount,
    required super.shippingCost,
    required super.appliesToShipping,
    required super.taxableAmount,
    required super.itemsTax,
    required super.shippingTax,
    required super.totalTax,
  });

  factory TaxPreviewModel.fromJson(Map<String, dynamic> json) {
    return TaxPreviewModel(
      taxApplied: json['taxApplied'] == true,
      taxRuleId: json['taxRuleId']?.toString(),
      taxRuleName: _cleanText(json['taxRuleName']),
      taxRate: _doubleFromJson(json['taxRate']) ?? 0,
      itemsSubtotal: _doubleFromJson(json['itemsSubtotal']) ?? 0,
      promotionDiscount: _doubleFromJson(json['promotionDiscount']) ?? 0,
      taxableItemsAmount: _doubleFromJson(json['taxableItemsAmount']) ?? 0,
      shippingCost: _doubleFromJson(json['shippingCost']) ?? 0,
      appliesToShipping: json['appliesToShipping'] == true,
      taxableAmount: _doubleFromJson(json['taxableAmount']) ?? 0,
      itemsTax: _doubleFromJson(json['itemsTax']) ?? 0,
      shippingTax: _doubleFromJson(json['shippingTax']) ?? 0,
      totalTax: _doubleFromJson(json['totalTax']) ?? 0,
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
}