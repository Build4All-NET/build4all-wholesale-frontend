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
    super.statusUpdatedAt,
    super.deliveredAt,
    super.notes,
  });

  factory SupplierOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ??
        json['orderItems'] ??
        json['products'] ??
        json['order_items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => SupplierOrderItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <SupplierOrderItemModel>[];

    return SupplierOrderModel(
      id: _asInt(
        json['id'] ??
            json['orderId'] ??
            json['supplierOrderId'] ??
            json['order_id'],
      ),
      orderNumber: _asString(
        json['orderNumber'] ??
            json['orderCode'] ??
            json['reference'] ??
            json['order_number'],
        fallback: _fallbackOrderNumber(json),
      ),
      retailerName: _asString(
        json['retailerStoreName'] ??
            json['retailerName'] ??
            json['storeName'] ??
            json['customerName'] ??
            json['retailer_store_name'],
        fallback: 'Retailer',
      ),
      retailerPhone: _asString(
        json['retailerPhoneNumber'] ??
            json['retailerPhone'] ??
            json['phoneNumber'] ??
            json['phone'] ??
            json['retailer_phone_number'],
      ),
      deliveryAddress: _asString(
        json['deliveryAddress'] ??
            json['address'] ??
            json['shippingAddress'] ??
            json['delivery_address'],
      ),
      branchName: _nullableString(
        json['branchName'] ??
            json['supplierBranchName'] ??
            json['branch'] ??
            json['branch_name'],
      ),
      orderDate: _asDateTime(
        json['createdAt'] ??
            json['orderDate'] ??
            json['createdDate'] ??
            json['created_at'] ??
            json['createdOn'] ??
            json['created_on'],
      ),
      statusUpdatedAt: _nullableDateTime(
        json['statusUpdatedAt'] ??
            json['status_updated_at'] ??
            json['lastStatusUpdatedAt'] ??
            json['updatedAt'] ??
            json['updated_at'],
      ),
      deliveredAt: _nullableDateTime(
        json['deliveredAt'] ??
            json['delivered_at'] ??
            json['deliveryCompletedAt'] ??
            json['delivery_completed_at'],
      ),
      paymentMethod: _asString(
        json['paymentMethod'] ??
            json['paymentType'] ??
            json['payment_method'],
        fallback: 'N/A',
      ),
      status: _statusFromJson(json['status']),
      items: items,
      notes: _nullableString(
        json['notes'] ?? json['note'] ?? json['comment'],
      ),
    );
  }

  static String _fallbackOrderNumber(Map<String, dynamic> json) {
    final id = json['id'] ?? json['orderId'] ?? json['supplierOrderId'];

    if (id == null) return 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    final parsedId = _asInt(id);
    return 'ORD-${parsedId.toString().padLeft(3, '0')}';
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
      case 'COMPLETED':
        return SupplierOrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return SupplierOrderStatus.cancelled;
      default:
        return SupplierOrderStatus.pending;
    }
  }

  static DateTime _asDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value.toLocal();

    final parsed = DateTime.tryParse(value.toString());

    if (parsed == null) return DateTime.now();

    return parsed.toLocal();
  }

  static DateTime? _nullableDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value.toLocal();

    final parsed = DateTime.tryParse(value.toString());

    if (parsed == null) return null;

    return parsed.toLocal();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }

    return text;
  }
}