import 'package:equatable/equatable.dart';

class TaxPreviewEntity extends Equatable {
  final bool taxApplied;
  final String? taxRuleId;
  final String? taxRuleName;
  final double taxRate;

  final double itemsSubtotal;
  final double promotionDiscount;
  final double taxableItemsAmount;

  final double shippingCost;
  final bool appliesToShipping;

  final double taxableAmount;
  final double itemsTax;
  final double shippingTax;
  final double totalTax;

  const TaxPreviewEntity({
    required this.taxApplied,
    this.taxRuleId,
    this.taxRuleName,
    required this.taxRate,
    required this.itemsSubtotal,
    required this.promotionDiscount,
    required this.taxableItemsAmount,
    required this.shippingCost,
    required this.appliesToShipping,
    required this.taxableAmount,
    required this.itemsTax,
    required this.shippingTax,
    required this.totalTax,
  });

  String get taxRateLabel => '${_cleanNumber(taxRate)}%';

  String get totalTaxLabel => '\$${_cleanNumber(totalTax)}';

  String get appliedRuleLabel {
    if (!taxApplied) return 'No tax rule applied';
    return taxRuleName ?? 'Tax rule';
  }

  static String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [
        taxApplied,
        taxRuleId,
        taxRuleName,
        taxRate,
        itemsSubtotal,
        promotionDiscount,
        taxableItemsAmount,
        shippingCost,
        appliesToShipping,
        taxableAmount,
        itemsTax,
        shippingTax,
        totalTax,
      ];
}