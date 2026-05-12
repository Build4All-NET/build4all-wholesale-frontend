class RfqQuotationEntity {
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

  const RfqQuotationEntity({
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

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isWithdrawn => status.toUpperCase() == 'WITHDRAWN';
}
