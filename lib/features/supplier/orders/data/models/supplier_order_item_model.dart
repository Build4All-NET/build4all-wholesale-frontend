import '../../domain/entities/supplier_order_item_entity.dart';

class SupplierOrderItemModel extends SupplierOrderItemEntity {
  SupplierOrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory SupplierOrderItemModel.fromJson(Map<String, dynamic> json) {
    return SupplierOrderItemModel(
      productId: _asInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      quantity: _asInt(json['quantity']),
      unitPrice: _asDouble(json['unitPrice']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}