import '../../domain/entities/retailer_order_entity.dart';
import 'retailer_order_item_model.dart';

class RetailerOrderModel extends RetailerOrderEntity {
  const RetailerOrderModel({
    required super.id,
    required super.orderNumber,
    required super.retailerStoreName,
    required super.retailerPhoneNumber,
    required super.branchId,
    required super.branchName,
    required super.branchCity,
    required super.branchAddress,
    required super.status,
    required super.deliveryAddress,
    required super.paymentMethod,
    required super.notes,
    required super.totalAmount,
    required super.totalItems,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
  });

  factory RetailerOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['orderItems'] ?? json['order_items'];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => RetailerOrderItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <RetailerOrderItemModel>[];

    final id = _asInt(json['id'] ?? json['orderId'] ?? json['order_id']);

    return RetailerOrderModel(
      id: id,
      orderNumber: _asString(
        json['orderNumber'] ??
            json['order_number'] ??
            json['reference'] ??
            json['orderReference'],
        fallback: 'ORD-${id.toString().padLeft(4, '0')}',
      ),
      retailerStoreName: _nullableString(
        json['retailerStoreName'] ?? json['retailer_store_name'],
      ),
      retailerPhoneNumber: _nullableString(
        json['retailerPhoneNumber'] ?? json['retailer_phone_number'],
      ),
      branchId: _nullableInt(json['branchId'] ?? json['branch_id']),
      branchName: _nullableString(json['branchName'] ?? json['branch_name']),
      branchCity: _nullableString(json['branchCity'] ?? json['branch_city']),
      branchAddress: _nullableString(
        json['branchAddress'] ?? json['branch_address'],
      ),
      status: _statusFromJson(json['status']),
      deliveryAddress: _asString(
        json['deliveryAddress'] ?? json['delivery_address'],
      ),
      paymentMethod: _asString(
        json['paymentMethod'] ?? json['payment_method'],
        fallback: 'N/A',
      ),
      notes: _nullableString(json['notes'] ?? json['note']),
      totalAmount: _asDouble(json['totalAmount'] ?? json['total_amount']),
      totalItems: _asInt(json['totalItems'] ?? json['total_items'],
          fallback: parsedItems.fold<int>(0, (sum, item) => sum + item.quantity)),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _nullableDateTime(json['updatedAt'] ?? json['updated_at']),
      items: parsedItems,
    );
  }

  static RetailerOrderStatus _statusFromJson(dynamic value) {
    final status = value?.toString().trim().toUpperCase();
    switch (status) {
      case 'PENDING_PAYMENT':
      case 'AWAITING_PAYMENT':
        return RetailerOrderStatus.pendingPayment;
      case 'ACCEPTED':
      case 'CONFIRMED':
        return RetailerOrderStatus.accepted;
      case 'PREPARING':
      case 'PROCESSING':
        return RetailerOrderStatus.preparing;
      case 'SHIPPED':
        return RetailerOrderStatus.shipped;
      case 'DELIVERED':
      case 'COMPLETED':
        return RetailerOrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return RetailerOrderStatus.cancelled;
      case 'PENDING':
      default:
        return RetailerOrderStatus.pending;
    }
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) return value.toLocal();
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return (parsed ?? DateTime.now()).toLocal();
  }

  static DateTime? _nullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return fallback;
    return text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }
}
