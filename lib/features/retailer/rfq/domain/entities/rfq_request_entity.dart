import 'rfq_quotation_entity.dart';

class RfqRequestEntity {
  final int id;

  final int? retailerBuild4allUserId;
  final int? ownerProjectLinkId;

  final String productName;
  final String requirements;
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

  final String status;

  final int quotationsCount;
  final List<RfqQuotationEntity> quotations;

  final DateTime? submittedAt;
  final DateTime? closedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RfqRequestEntity({
    required this.id,
    this.retailerBuild4allUserId,
    this.ownerProjectLinkId,
    required this.productName,
    required this.requirements,
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
    required this.aiGenerated,
    required this.status,
    required this.quotationsCount,
    this.quotations = const [],
    this.submittedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  });

  String get normalizedStatus => status.toUpperCase();

  bool get isOpen => normalizedStatus == 'OPEN';
  bool get isQuoted => normalizedStatus == 'QUOTED';
  bool get isAccepted => normalizedStatus == 'ACCEPTED';
  bool get isClosed => normalizedStatus == 'CLOSED';
  bool get isCancelled => normalizedStatus == 'CANCELLED';
  bool get isExpired => normalizedStatus == 'EXPIRED';

  bool get hasSupplierQuotations =>
      quotationsCount > 0 || quotations.isNotEmpty;

  /// Professional B2B rule:
  /// Edit is safe only while supplier has not quoted yet.
  bool get canEdit => isOpen && !hasSupplierQuotations;

  /// Professional B2B rule:
  /// Deleting is safe only if no supplier interacted with this RFQ.
  bool get canDelete => isOpen && !hasSupplierQuotations;

  /// Professional B2B rule:
  /// If suppliers may have already seen/quoted the RFQ, cancel it instead of deleting.
  bool get canCancel => isOpen || isQuoted;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  String get quantityLabel => '$quantity $unit';

  String get deliveryLocationLabel {
    final parts = [
      deliveryCity,
      deliveryRegionName,
      deliveryCountryName,
    ].where((value) => value != null && value.trim().isNotEmpty).toList();

    if (parts.isEmpty) return 'No delivery location added';

    return parts.join(', ');
  }
}
