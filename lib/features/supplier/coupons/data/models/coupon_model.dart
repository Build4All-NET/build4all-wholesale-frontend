import '../../domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.ownerProjectId,
    required super.code,
    super.description,
    required super.discountType,
    required super.discountValue,
    super.maxUses,
    super.usedCount = 0,
    super.minOrderAmount,
    super.maxDiscountAmount,
    super.startsAt,
    super.expiresAt,
    required super.active,
    super.branchScope = CouponBranchScope.allBranches,
    super.selectedBranchIds = const [],
    super.selectedBranchNames = const [],
  });

  factory CouponModel.fromEntity(CouponEntity entity) {
    return CouponModel(
      id: entity.id,
      ownerProjectId: entity.ownerProjectId,
      code: entity.code,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      maxUses: entity.maxUses,
      usedCount: entity.usedCount,
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

  factory CouponModel.fromBackendJson(Map<String, dynamic> json) {
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

    return CouponModel(
      id: json['id']?.toString() ?? '',
      ownerProjectId: 0,
      code: json['code']?.toString() ?? '',
      description: _toNullableString(json['description']),
      discountType: CouponDiscountTypeX.fromBackend(
        json['discountType']?.toString(),
      ),
      discountValue: _toDouble(json['discountValue']),
      maxUses: _toInt(json['usageLimit']),
      usedCount: _toInt(json['usageCount']) ?? 0,
      minOrderAmount: _toDoubleNullable(json['minOrderAmount']),
      maxDiscountAmount: _toDoubleNullable(json['maxDiscountAmount']),
      startsAt: _toDateTime(json['startDate']),
      expiresAt: _toDateTime(json['endDate']),
      active: json['active'] == true,
      branchScope: appliesToAllBranches
          ? CouponBranchScope.allBranches
          : CouponBranchScope.selectedBranches,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
    );
  }

  Map<String, dynamic> toBackendCreateJson() {
    return {
      'code': code.trim().toUpperCase(),
      'description': description,
      'discountType': discountType.backendValue,
      'discountValue':
          discountType == CouponDiscountType.freeShipping ? 0 : discountValue,
      'usageLimit': maxUses,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount':
          discountType == CouponDiscountType.percent ? maxDiscountAmount : null,
      'startDate': startsAt?.toIso8601String(),
      'endDate': expiresAt?.toIso8601String(),
      'active': active,
      'appliesToAllBranches': branchScope == CouponBranchScope.allBranches,
      'selectedBranchIds': branchScope == CouponBranchScope.allBranches
          ? <int>[]
          : selectedBranchIds
              .map((id) => int.tryParse(id))
              .whereType<int>()
              .toList(),
    };
  }

  CouponEntity toEntity() {
    return CouponEntity(
      id: id,
      ownerProjectId: ownerProjectId,
      code: code,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      maxUses: maxUses,
      usedCount: usedCount,
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}