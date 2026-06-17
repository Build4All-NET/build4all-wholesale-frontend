import 'supplier_order_item_entity.dart';

enum SupplierOrderStatus {
  pendingPayment,
  pending,
  accepted,
  preparing,
  shipped,
  delivered,
  cancelled,
}

extension SupplierOrderStatusExtension on SupplierOrderStatus {
  String get label {
    switch (this) {
      case SupplierOrderStatus.pendingPayment:
        return 'Awaiting Payment';
      case SupplierOrderStatus.pending:
        return 'Pending';
      case SupplierOrderStatus.accepted:
        return 'Accepted';
      case SupplierOrderStatus.preparing:
        return 'Preparing';
      case SupplierOrderStatus.shipped:
        return 'Shipped';
      case SupplierOrderStatus.delivered:
        return 'Delivered';
      case SupplierOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class SupplierOrderEntity {
  final int id;
  final String orderNumber;
  final String retailerName;
  final String retailerPhone;
  final String deliveryAddress;
  final String? branchName;

  /// Date when the order was created.
  /// Used for Orders Today.
  final DateTime orderDate;

  /// Date when the status was last updated.
  /// Used as fallback for sales date if deliveredAt is not available.
  final DateTime? statusUpdatedAt;

  /// Date when the order was delivered.
  /// Best field for Today's Sales and Monthly Revenue if backend sends it.
  final DateTime? deliveredAt;

  final String paymentMethod;
  final double? backendTotalAmount;
  final SupplierOrderStatus status;
  final List<SupplierOrderItemEntity> items;
  final String? notes;

  SupplierOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.retailerName,
    required this.retailerPhone,
    required this.deliveryAddress,
    required this.branchName,
    required this.orderDate,
    required this.paymentMethod,
    this.backendTotalAmount,
    required this.status,
    required this.items,
    this.statusUpdatedAt,
    this.deliveredAt,
    this.notes,
  });

  int get itemCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    if (backendTotalAmount != null) return backendTotalAmount!;
    return items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  SupplierOrderEntity copyWith({
    int? id,
    String? orderNumber,
    String? retailerName,
    String? retailerPhone,
    String? deliveryAddress,
    String? branchName,
    DateTime? orderDate,
    DateTime? statusUpdatedAt,
    DateTime? deliveredAt,
    String? paymentMethod,
    double? backendTotalAmount,
    SupplierOrderStatus? status,
    List<SupplierOrderItemEntity>? items,
    String? notes,
  }) {
    return SupplierOrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      retailerName: retailerName ?? this.retailerName,
      retailerPhone: retailerPhone ?? this.retailerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      branchName: branchName ?? this.branchName,
      orderDate: orderDate ?? this.orderDate,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      backendTotalAmount: backendTotalAmount ?? this.backendTotalAmount,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}