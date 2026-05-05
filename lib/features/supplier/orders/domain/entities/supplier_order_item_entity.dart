class SupplierOrderItemEntity {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SupplierOrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}