import '../../domain/entities/rfq_quotation_entity.dart';

class RfqQuotationModel extends RfqQuotationEntity {
  const RfqQuotationModel({
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

  factory RfqQuotationModel.fromJson(Map<String, dynamic> json) {
    return RfqQuotationModel(
      id: _toInt(json['id']),
      rfqId: _toNullableInt(json['rfqId']),
      supplierBuild4allUserId: _toNullableInt(
        json['supplierBuild4allUserId'],
      ),
      supplierUsername: json['supplierUsername']?.toString(),
      supplierEmail: json['supplierEmail']?.toString(),
      unitPrice: _toDouble(json['unitPrice']),
      totalPrice: _toDouble(json['totalPrice']),
      availableQuantity: _toNullableInt(json['availableQuantity']),
      deliveryDate: _toDate(json['deliveryDate']),
      shippingCost: _toNullableDouble(json['shippingCost']),
      message: json['message']?.toString(),
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
}