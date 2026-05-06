import '../../domain/entities/supplier_order_entity.dart';
import 'supplier_order_item_model.dart';

class SupplierOrderModel extends SupplierOrderEntity {
  const SupplierOrderModel({
    required super.id,
    required super.orderNumber,
    required super.retailerName,
    required super.retailerPhone,
    required super.deliveryAddress,
    required super.branchName,
    required super.orderDate,
    required super.paymentMethod,
    required super.status,
    required super.items,
    super.notes,
  });

  factory SupplierOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
            .map(
              (item) => SupplierOrderItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList()
        : <SupplierOrderItemModel>[];

    return SupplierOrderModel(
      id: _asInt(json['id'] ?? json['orderId']),
      orderNumber: json['orderNumber']?.toString() ?? '',
      retailerName: json['retailerStoreName']?.toString() ??
          json['retailerName']?.toString() ??
          'Retailer',
      retailerPhone: json['retailerPhoneNumber']?.toString() ??
          json['retailerPhone']?.toString() ??
          '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      branchName: json['branchName']?.toString(),
      orderDate: _asDateTime(json['createdAt'] ?? json['orderDate']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: _statusFromJson(json['status']),
      items: items,
      notes: json['notes']?.toString(),
    );
  }

  static SupplierOrderStatus _statusFromJson(dynamic value) {
    final status = value?.toString().trim().toUpperCase();

    switch (status) {
      case 'PENDING':
        return SupplierOrderStatus.pending;
      case 'ACCEPTED':
        return SupplierOrderStatus.accepted;
      case 'PREPARING':
        return SupplierOrderStatus.preparing;
      case 'SHIPPED':
        return SupplierOrderStatus.shipped;
      case 'DELIVERED':
        return SupplierOrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
        return SupplierOrderStatus.cancelled;
      default:
        return SupplierOrderStatus.pending;
    }
  }

  static DateTime _asDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}