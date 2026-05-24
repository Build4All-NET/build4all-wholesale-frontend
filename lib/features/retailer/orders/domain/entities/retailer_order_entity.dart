import 'retailer_order_item_entity.dart';

enum RetailerOrderStatus {
  pending,
  accepted,
  preparing,
  shipped,
  delivered,
  cancelled,
}

enum RetailerOrderFilter {
  all,
  pending,
  delivered,
  cancelled,
}

class RetailerOrderEntity {
  final int id;
  final String orderNumber;
  final String? retailerStoreName;
  final String? retailerPhoneNumber;
  final int? branchId;
  final String? branchName;
  final String? branchCity;
  final String? branchAddress;
  final RetailerOrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RetailerOrderItemEntity> items;

  const RetailerOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.retailerStoreName,
    required this.retailerPhoneNumber,
    required this.branchId,
    required this.branchName,
    required this.branchCity,
    required this.branchAddress,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.notes,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  bool get isPendingGroup {
    return status == RetailerOrderStatus.pending ||
        status == RetailerOrderStatus.accepted ||
        status == RetailerOrderStatus.preparing ||
        status == RetailerOrderStatus.shipped;
  }

  bool get canCancel {
    return status == RetailerOrderStatus.pending ||
        status == RetailerOrderStatus.accepted;
  }

  bool get canReorder {
    return status == RetailerOrderStatus.delivered ||
        status == RetailerOrderStatus.cancelled;
  }
}
