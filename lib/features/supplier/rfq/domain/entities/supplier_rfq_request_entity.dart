import 'supplier_rfq_quotation_entity.dart';

class SupplierRfqRequestEntity {
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
  final List<SupplierRfqQuotationEntity> quotations;
  final DateTime? submittedAt;
  final DateTime? closedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierRfqRequestEntity({
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
  bool get canQuote => isOpen || isQuoted;
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  String get quantityLabel => '$quantity $unit';

  SupplierRfqQuotationEntity? get myQuotation {
    if (quotations.isEmpty) return null;
    final active = quotations.where((q) => !q.isWithdrawn).toList();
    if (active.isNotEmpty) return active.first;
    return quotations.first;
  }

  bool get hasMyQuotation => myQuotation != null;
  bool get canSubmitQuotation => canQuote && !hasMyQuotation;

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
