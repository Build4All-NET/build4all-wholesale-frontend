enum CouponDiscountType {
  percent,
  fixed,
  freeShipping,
}

extension CouponDiscountTypeX on CouponDiscountType {
  String get label {
    switch (this) {
      case CouponDiscountType.percent:
        return 'Percent';
      case CouponDiscountType.fixed:
        return 'Fixed';
      case CouponDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }
}

enum CouponBranchScope {
  allBranches,
  selectedBranches,
}

extension CouponBranchScopeX on CouponBranchScope {
  String get label {
    switch (this) {
      case CouponBranchScope.allBranches:
        return 'All Branches';
      case CouponBranchScope.selectedBranches:
        return 'Selected Branches';
    }
  }
}

class CouponEntity {
  final String id;
  final int ownerProjectId;
  final String code;
  final String? description;
  final CouponDiscountType discountType;
  final double discountValue;
  final int? maxUses;
  final int usedCount;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool active;
  final CouponBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;

  const CouponEntity({
    required this.id,
    required this.ownerProjectId,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxUses,
    this.usedCount = 0,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startsAt,
    this.expiresAt,
    required this.active,
    this.branchScope = CouponBranchScope.allBranches,
    this.selectedBranchIds = const [],
    this.selectedBranchNames = const [],
  });

  int? get remainingUses {
    if (maxUses == null) return null;
    final remaining = maxUses! - usedCount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get started {
    if (startsAt == null) return true;
    return !DateTime.now().isBefore(startsAt!);
  }

  bool get expired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get usageLimitReached {
    if (maxUses == null) return false;
    return usedCount >= maxUses!;
  }

  bool get currentlyValid {
    return active && started && !expired && !usageLimitReached;
  }

  String get status {
    if (!active) return 'INACTIVE';
    if (!started) return 'SCHEDULED';
    if (expired) return 'EXPIRED';
    if (usageLimitReached) return 'USAGE_LIMIT_REACHED';
    return 'ACTIVE';
  }

  String get statusLabel {
    switch (status) {
      case 'INACTIVE':
        return 'Inactive';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'EXPIRED':
        return 'Expired';
      case 'USAGE_LIMIT_REACHED':
        return 'Limit reached';
      case 'ACTIVE':
      default:
        return 'Active';
    }
  }

  String get discountLabel {
    switch (discountType) {
      case CouponDiscountType.percent:
        return '${discountValue.toStringAsFixed(0)} %';
      case CouponDiscountType.fixed:
        return discountValue.toStringAsFixed(2);
      case CouponDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }

  String get branchApplicabilityLabel {
    if (branchScope == CouponBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  CouponEntity copyWith({
    String? id,
    int? ownerProjectId,
    String? code,
    String? description,
    CouponDiscountType? discountType,
    double? discountValue,
    int? maxUses,
    int? usedCount,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? active,
    CouponBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
  }) {
    return CouponEntity(
      id: id ?? this.id,
      ownerProjectId: ownerProjectId ?? this.ownerProjectId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
      branchScope: branchScope ?? this.branchScope,
      selectedBranchIds: selectedBranchIds ?? this.selectedBranchIds,
      selectedBranchNames: selectedBranchNames ?? this.selectedBranchNames,
    );
  }
}