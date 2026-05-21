import '../../domain/entities/retailer_order_item_entity.dart';

class RetailerOrderItemModel extends RetailerOrderItemEntity {
  const RetailerOrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.imageUrl,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
  });

  factory RetailerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return RetailerOrderItemModel(
      id: _asInt(json['id'] ?? json['orderItemId'] ?? json['order_item_id']),
      productId: _asInt(json['productId'] ?? json['product_id']),
      productName: _asString(
        json['productName'] ??
            json['product_name'] ??
            json['productNameSnapshot'] ??
            json['name'],
      ),
      imageUrl: _nullableString(
        json['imageUrl'] ?? json['image_url'] ?? json['productImageUrl'],
      ),
      quantity: _asInt(json['quantity']),
      unitPrice: _asDouble(json['unitPrice'] ?? json['unit_price']),
      totalPrice: _asDouble(
        json['totalPrice'] ??
            json['total_price'] ??
            (_asDouble(json['unitPrice']) * _asInt(json['quantity'])),
      ),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
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
