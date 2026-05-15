class SupplierRfqQuotationEntity {
  final int id;
  final int? rfqId;
  final int? supplierBuild4allUserId;
  final String? supplierUsername;
  final String? supplierEmail;
  final double unitPrice;
  final double totalPrice;
  final int? availableQuantity;
  final DateTime? deliveryDate;
  final double? shippingCost;
  final String? message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierRfqQuotationEntity({
    required this.id,
    this.rfqId,
    this.supplierBuild4allUserId,
    this.supplierUsername,
    this.supplierEmail,
    required this.unitPrice,
    required this.totalPrice,
    this.availableQuantity,
    this.deliveryDate,
    this.shippingCost,
    this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  String get normalizedStatus => status.toUpperCase();
  bool get isPending => normalizedStatus == 'PENDING';
  bool get isAccepted => normalizedStatus == 'ACCEPTED';
  bool get isRejected => normalizedStatus == 'REJECTED';
  bool get isWithdrawn => normalizedStatus == 'WITHDRAWN';
  bool get canEdit => isPending;
  bool get canWithdraw => isPending;
}
