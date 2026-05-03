class CouponEntity {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final String expiryDate;
  final int? usageLimit;
  final bool isActive;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expiryDate,
    this.usageLimit,
    required this.isActive,
  });

  String get status => isActive ? 'Active' : 'Inactive';

  String get discountLabel {
    if (discountType.toLowerCase() == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}% Off';
    }

    return '\$${discountValue.toStringAsFixed(0)} Off';
  }
}