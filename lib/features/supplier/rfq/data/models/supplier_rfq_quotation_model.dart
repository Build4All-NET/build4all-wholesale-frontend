import '../../domain/entities/supplier_rfq_quotation_entity.dart';

class SupplierRfqQuotationModel extends SupplierRfqQuotationEntity {
  const SupplierRfqQuotationModel({
    required super.id,
    super.rfqId,
    super.supplierBuild4allUserId,
    super.supplierUsername,
    super.supplierEmail,
    required super.unitPrice,
    required super.totalPrice,
    super.availableQuantity,
    super.deliveryDate,
    super.shippingCost,
    super.message,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory SupplierRfqQuotationModel.fromJson(Map<String, dynamic> json) {
    return SupplierRfqQuotationModel(
      id: _toInt(json['id']),
      rfqId: _toNullableInt(json['rfqId']),
      supplierBuild4allUserId: _toNullableInt(json['supplierBuild4allUserId']),
      supplierUsername: _emptyToNull(json['supplierUsername']?.toString()),
      supplierEmail: _emptyToNull(json['supplierEmail']?.toString()),
      unitPrice: _toDouble(json['unitPrice']),
      totalPrice: _toDouble(json['totalPrice']),
      availableQuantity: _toNullableInt(json['availableQuantity']),
      deliveryDate: _toDate(json['deliveryDate']),
      shippingCost: _toNullableDouble(json['shippingCost']),
      message: _emptyToNull(json['message']?.toString()),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
