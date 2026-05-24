import '../../domain/entities/supplier_rfq_request_entity.dart';
import 'supplier_rfq_quotation_model.dart';

class SupplierRfqRequestModel extends SupplierRfqRequestEntity {
  const SupplierRfqRequestModel({
    required super.id,
    super.retailerBuild4allUserId,
    super.ownerProjectLinkId,
    required super.productName,
    required super.requirements,
    super.imageUrl,
    super.categoryId,
    super.categoryName,
    super.subCategoryId,
    super.subCategoryName,
    super.productId,
    required super.quantity,
    required super.unit,
    super.targetUnitPrice,
    required super.preferredDeliveryLabel,
    super.preferredDeliveryDays,
    super.deadlineDate,
    super.deliveryCountryId,
    super.deliveryCountryName,
    super.deliveryCountryIso2Code,
    super.deliveryCountryIso3Code,
    super.deliveryRegionId,
    super.deliveryRegionName,
    super.deliveryRegionCode,
    super.deliveryCity,
    super.deliveryAddress,
    required super.aiGenerated,
    required super.status,
    required super.quotationsCount,
    super.quotations,
    super.submittedAt,
    super.closedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory SupplierRfqRequestModel.fromJson(Map<String, dynamic> json) {
    final rawQuotations = json['quotations'];

    return SupplierRfqRequestModel(
      id: _toInt(json['id']),
      retailerBuild4allUserId: _toNullableInt(json['retailerBuild4allUserId']),
      ownerProjectLinkId: _toNullableInt(json['ownerProjectLinkId']),
      productName: json['productName']?.toString() ?? '',
      requirements: json['requirements']?.toString() ?? '',
      imageUrl: _emptyToNull(json['imageUrl']?.toString()),
      categoryId: _toNullableInt(json['categoryId']),
      categoryName: _emptyToNull(json['categoryName']?.toString()),
      subCategoryId: _toNullableInt(json['subCategoryId']),
      subCategoryName: _emptyToNull(json['subCategoryName']?.toString()),
      productId: _toNullableInt(json['productId']),
      quantity: _toInt(json['quantity']),
      unit: json['unit']?.toString() ?? 'units',
      targetUnitPrice: _toNullableDouble(json['targetUnitPrice']),
      preferredDeliveryLabel:
          json['preferredDeliveryLabel']?.toString() ?? 'Within 1 week',
      preferredDeliveryDays: _toNullableInt(json['preferredDeliveryDays']),
      deadlineDate: _toDate(json['deadlineDate']),
      deliveryCountryId: _toNullableInt(json['deliveryCountryId']),
      deliveryCountryName: _emptyToNull(json['deliveryCountryName']?.toString()),
      deliveryCountryIso2Code:
          _emptyToNull(json['deliveryCountryIso2Code']?.toString()),
      deliveryCountryIso3Code:
          _emptyToNull(json['deliveryCountryIso3Code']?.toString()),
      deliveryRegionId: _toNullableInt(json['deliveryRegionId']),
      deliveryRegionName: _emptyToNull(json['deliveryRegionName']?.toString()),
      deliveryRegionCode: _emptyToNull(json['deliveryRegionCode']?.toString()),
      deliveryCity: _emptyToNull(json['deliveryCity']?.toString()),
      deliveryAddress: _emptyToNull(json['deliveryAddress']?.toString()),
      aiGenerated: json['aiGenerated'] == true,
      status: json['status']?.toString() ?? 'OPEN',
      quotationsCount: _toInt(json['quotationsCount']),
      quotations: rawQuotations is List
          ? rawQuotations
              .whereType<Map>()
              .map(
                (item) => SupplierRfqQuotationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      submittedAt: _toDate(json['submittedAt']),
      closedAt: _toDate(json['closedAt']),
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
