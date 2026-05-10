import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    super.description,
    required super.discountType,
    required super.discountValue,
    super.minOrderAmount,
    super.maxDiscountAmount,
    super.startsAt,
    super.expiresAt,
    required super.active,
    super.branchScope = PromotionBranchScope.allBranches,
    super.selectedBranchIds = const [],
    super.selectedBranchNames = const [],
  });

  factory PromotionModel.fromEntity(PromotionEntity entity) {
    return PromotionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      minOrderAmount: entity.minOrderAmount,
      maxDiscountAmount: entity.maxDiscountAmount,
      startsAt: entity.startsAt,
      expiresAt: entity.expiresAt,
      active: entity.active,
      branchScope: entity.branchScope,
      selectedBranchIds: entity.selectedBranchIds,
      selectedBranchNames: entity.selectedBranchNames,
    );
  }

  factory PromotionModel.fromBackendJson(Map<String, dynamic> json) {
    final selectedBranchesRaw = json['selectedBranches'];

    final selectedBranchIds = <String>[];
    final selectedBranchNames = <String>[];

    if (selectedBranchesRaw is List) {
      for (final item in selectedBranchesRaw) {
        if (item is Map) {
          final branch = Map<String, dynamic>.from(item);
          final branchId = branch['id']?.toString();
          final branchName = branch['name']?.toString();

          if (branchId != null && branchId.isNotEmpty) {
            selectedBranchIds.add(branchId);
          }

          if (branchName != null && branchName.isNotEmpty) {
            selectedBranchNames.add(branchName);
          }
        }
      }
    }

    final appliesToAllBranches = json['appliesToAllBranches'] == true;

    return PromotionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: _toNullableString(json['description']),
      discountType: PromotionDiscountTypeX.fromBackend(
        json['discountType']?.toString(),
      ),
      discountValue: _toDouble(json['discountValue']),
      minOrderAmount: _toDoubleNullable(json['minOrderAmount']),
      maxDiscountAmount: _toDoubleNullable(json['maxDiscountAmount']),
      startsAt: _toDateTime(json['startDate']),
      expiresAt: _toDateTime(json['endDate']),
      active: json['active'] == true,
      branchScope: appliesToAllBranches
          ? PromotionBranchScope.allBranches
          : PromotionBranchScope.selectedBranches,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
    );
  }

  Map<String, dynamic> toBackendCreateJson() {
    return {
      'title': title.trim(),
      'description': description,
      'discountType': discountType.backendValue,
      'discountValue':
          discountType == PromotionDiscountType.freeShipping ? 0 : discountValue,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount':
          discountType == PromotionDiscountType.percent ? maxDiscountAmount : null,
      'startDate': startsAt?.toIso8601String(),
      'endDate': expiresAt?.toIso8601String(),
      'active': active,
      'appliesToAllBranches': branchScope == PromotionBranchScope.allBranches,
      'selectedBranchIds': branchScope == PromotionBranchScope.allBranches
          ? <int>[]
          : selectedBranchIds
              .map((id) => int.tryParse(id))
              .whereType<int>()
              .toList(),
    };
  }

  PromotionEntity toEntity() {
    return PromotionEntity(
      id: id,
      title: title,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      minOrderAmount: minOrderAmount,
      maxDiscountAmount: maxDiscountAmount,
      startsAt: startsAt,
      expiresAt: expiresAt,
      active: active,
      branchScope: branchScope,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
    );
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    return text;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}