import '../entities/rfq_quotation_entity.dart';
import '../entities/rfq_request_entity.dart';

class CreateRfqParams {
  final String productName;
  final String requirements;
  final String? imagePath;
  final String? imageUrl;

  final int? categoryId;
  final String? categoryName;

  final int? subCategoryId;
  final String? subCategoryName;

  final int? productId;

  final int quantity;
  final String unit;

  final double? targetUnitPrice;

  final String preferredDeliveryLabel;
  final int? preferredDeliveryDays;

  final DateTime? deadlineDate;

  final int? deliveryCountryId;
  final String? deliveryCountryName;
  final String? deliveryCountryIso2Code;
  final String? deliveryCountryIso3Code;

  final int? deliveryRegionId;
  final String? deliveryRegionName;
  final String? deliveryRegionCode;

  final String? deliveryCity;
  final String? deliveryAddress;

  final bool aiGenerated;

  const CreateRfqParams({
    required this.productName,
    required this.requirements,
    this.imagePath,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.productId,
    required this.quantity,
    required this.unit,
    this.targetUnitPrice,
    required this.preferredDeliveryLabel,
    this.preferredDeliveryDays,
    this.deadlineDate,
    this.deliveryCountryId,
    this.deliveryCountryName,
    this.deliveryCountryIso2Code,
    this.deliveryCountryIso3Code,
    this.deliveryRegionId,
    this.deliveryRegionName,
    this.deliveryRegionCode,
    this.deliveryCity,
    this.deliveryAddress,
    this.aiGenerated = false,
  });
}

class UpdateRfqParams {
  final String productName;
  final String requirements;
  final String? imagePath;
  final String? imageUrl;

  final int? categoryId;
  final String? categoryName;

  final int? subCategoryId;
  final String? subCategoryName;

  final int? productId;

  final int quantity;
  final String unit;

  final double? targetUnitPrice;

  final String preferredDeliveryLabel;
  final int? preferredDeliveryDays;

  final DateTime? deadlineDate;

  final int? deliveryCountryId;
  final String? deliveryCountryName;
  final String? deliveryCountryIso2Code;
  final String? deliveryCountryIso3Code;

  final int? deliveryRegionId;
  final String? deliveryRegionName;
  final String? deliveryRegionCode;

  final String? deliveryCity;
  final String? deliveryAddress;

  final bool aiGenerated;

  const UpdateRfqParams({
    required this.productName,
    required this.requirements,
    this.imagePath,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.productId,
    required this.quantity,
    required this.unit,
    this.targetUnitPrice,
    required this.preferredDeliveryLabel,
    this.preferredDeliveryDays,
    this.deadlineDate,
    this.deliveryCountryId,
    this.deliveryCountryName,
    this.deliveryCountryIso2Code,
    this.deliveryCountryIso3Code,
    this.deliveryRegionId,
    this.deliveryRegionName,
    this.deliveryRegionCode,
    this.deliveryCity,
    this.deliveryAddress,
    this.aiGenerated = false,
  });
}

abstract class RetailerRfqRepository {
  Future<List<RfqRequestEntity>> getMyRfqs();

  Future<RfqRequestEntity> getRfqDetails(int rfqId);

  Future<RfqRequestEntity> createRfq(CreateRfqParams params);

  Future<RfqRequestEntity> updateRfq({
    required int rfqId,
    required UpdateRfqParams params,
  });

  Future<RfqRequestEntity> cancelRfq(int rfqId);

  Future<void> deleteRfq(int rfqId);

  Future<List<RfqQuotationEntity>> getRfqQuotations(int rfqId);

  Future<RfqRequestEntity> acceptQuotation({
    required int rfqId,
    required int quotationId,
  });
}
