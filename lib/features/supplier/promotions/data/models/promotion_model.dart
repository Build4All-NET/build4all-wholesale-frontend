import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    super.description,
    required super.discountType,
    required super.discountValue,
    super.targetType,
    super.targetId,
    super.targetName,
    super.minOrderAmount,
    super.maxDiscountAmount,
    super.startDate,
    super.endDate,
    required super.active,
    super.status,
    super.currentlyValid,
    required super.branchScope,
    super.selectedBranchIds,
    super.selectedBranchNames,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PromotionModel.fromEntity(PromotionEntity entity) {
    return PromotionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      targetType: entity.targetType,
      targetId: entity.targetId,
      targetName: entity.targetName,
      minOrderAmount: entity.minOrderAmount,
      maxDiscountAmount: entity.maxDiscountAmount,
      startDate: entity.startDate,
      endDate: entity.endDate,
      active: entity.active,
      status: entity.status,
      currentlyValid: entity.currentlyValid,
      branchScope: entity.branchScope,
      selectedBranchIds: entity.selectedBranchIds,
      selectedBranchNames: entity.selectedBranchNames,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final selectedBranchIds = <String>[];
    final selectedBranchNames = <String>[];

    final selectedBranches = json['selectedBranches'];
    if (selectedBranches is List) {
      for (final item in selectedBranches) {
        if (item is Map) {
          final branch = Map<String, dynamic>.from(item);
          final id = branch['id']?.toString();
          final name = branch['name']?.toString();

          if (id != null && id.trim().isNotEmpty) {
            selectedBranchIds.add(id);
          }

          if (name != null && name.trim().isNotEmpty) {
            selectedBranchNames.add(name);
          }
        }
      }
    }

    final appliesToAllBranches =
        json['appliesToAllBranches'] == null ||
            json['appliesToAllBranches'] == true;

    final targetType = PromotionTargetTypeX.fromBackendValue(
      json['targetType'],
    );

    return PromotionModel(
      id: json['id']?.toString() ?? '',
      title: _cleanText(json['title']) ?? '',
      description: _cleanText(json['description']),
      discountType: PromotionDiscountTypeX.fromBackendValue(
        json['discountType'],
      ),
      discountValue: _doubleFromJson(json['discountValue']) ?? 0,
      targetType: targetType,
      targetId: targetType == PromotionTargetType.allProducts
          ? null
          : json['targetId']?.toString(),
      targetName: _cleanText(json['targetName']),
      minOrderAmount: _doubleFromJson(json['minOrderAmount']),
      maxDiscountAmount: _doubleFromJson(json['maxDiscountAmount']),
      startDate: _dateFromJson(json['startDate'] ?? json['startsAt']),
      endDate: _dateFromJson(json['endDate'] ?? json['expiresAt']),
      active: json['active'] != false,
      status: _cleanText(json['status']),
      currentlyValid: json['currentlyValid'] == true,
      branchScope: appliesToAllBranches
          ? PromotionBranchScope.allBranches
          : PromotionBranchScope.selectedBranches,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title.trim(),
      'description':
          description == null || description!.trim().isEmpty
              ? null
              : description!.trim(),
      'discountType': discountType.backendValue,
      'discountValue': discountValue,
      'targetType': targetType.backendValue,
      'targetId': int.tryParse(targetId ?? ''),
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount':
          discountType == PromotionDiscountType.percent
              ? maxDiscountAmount
              : null,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'active': active,
      'appliesToAllBranches': true,
      'selectedBranchIds': <int>[],
    };
  }

  PromotionEntity toEntity() {
    return PromotionEntity(
      id: id,
      title: title,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      minOrderAmount: minOrderAmount,
      maxDiscountAmount: maxDiscountAmount,
      startDate: startDate,
      endDate: endDate,
      active: active,
      status: status,
      currentlyValid: currentlyValid,
      branchScope: branchScope,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _cleanText(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}