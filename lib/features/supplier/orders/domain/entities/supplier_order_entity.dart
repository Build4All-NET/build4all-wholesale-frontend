import 'supplier_order_item_entity.dart';

enum SupplierOrderStatus {
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
  final DateTime orderDate;
  final String paymentMethod;
  final SupplierOrderStatus status;
  final List<SupplierOrderItemEntity> items;
  final String? notes;

  const SupplierOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.retailerName,
    required this.retailerPhone,
    required this.deliveryAddress,
    required this.branchName,
    required this.orderDate,
    required this.paymentMethod,
    required this.status,
    required this.items,
    this.notes,
  });

  int get itemCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
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
    String? paymentMethod,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}