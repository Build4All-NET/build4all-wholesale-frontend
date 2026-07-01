class PlanPricing {
  final double? monthlyPrice;
  final double? yearlyPrice;
  final double? yearlyDiscountedPrice;
  final String currency;
  final int? discountPercent;
  final String? discountLabel;

  const PlanPricing({
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlyDiscountedPrice,
    required this.currency,
    required this.discountPercent,
    required this.discountLabel,
  });

  bool get hasYearlyDiscount =>
      yearlyDiscountedPrice != null &&
      yearlyPrice != null &&
      yearlyDiscountedPrice! < yearlyPrice!;

  /// Yearly price the user actually pays. `null` if neither a discounted
  /// nor a list yearly price is configured.
  double? get effectiveYearlyPrice => yearlyDiscountedPrice ?? yearlyPrice;
}
