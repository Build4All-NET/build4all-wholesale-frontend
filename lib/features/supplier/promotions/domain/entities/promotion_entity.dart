enum PromotionDiscountType {
  percent,
  fixed,
  freeShipping,
}

extension PromotionDiscountTypeX on PromotionDiscountType {
  String get label {
    switch (this) {
      case PromotionDiscountType.percent:
        return 'Percent';
      case PromotionDiscountType.fixed:
        return 'Fixed';
      case PromotionDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }
}

enum PromotionType {
  seasonal,
  flashSale,
  bulkOffer,
  general,
}

extension PromotionTypeX on PromotionType {
  String get label {
    switch (this) {
      case PromotionType.seasonal:
        return 'Seasonal';
      case PromotionType.flashSale:
        return 'Flash Sale';
      case PromotionType.bulkOffer:
        return 'Bulk Offer';
      case PromotionType.general:
        return 'General';
    }
  }
}

enum PromotionBranchScope {
  allBranches,
  selectedBranches,
}

extension PromotionBranchScopeX on PromotionBranchScope {
  String get label {
    switch (this) {
      case PromotionBranchScope.allBranches:
        return 'All Branches';
      case PromotionBranchScope.selectedBranches:
        return 'Selected Branches';
    }
  }
}

class PromotionEntity {
  final String id;
  final int ownerProjectId;
  final String title;
  final String? description;
  final PromotionType promotionType;
  final PromotionDiscountType discountType;
  final double discountValue;
  final int? maxUses;
  final int usedCount;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool active;
  final PromotionBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;

  const PromotionEntity({
    required this.id,
    required this.ownerProjectId,
    required this.title,
    this.description,
    required this.promotionType,
    required this.discountType,
    required this.discountValue,
    this.maxUses,
    this.usedCount = 0,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startsAt,
    this.endsAt,
    required this.active,
    this.branchScope = PromotionBranchScope.allBranches,
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
    if (endsAt == null) return false;
    return DateTime.now().isAfter(endsAt!);
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
      case PromotionDiscountType.percent:
        return '${discountValue.toStringAsFixed(0)} %';
      case PromotionDiscountType.fixed:
        return discountValue.toStringAsFixed(2);
      case PromotionDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }

  String get branchApplicabilityLabel {
    if (branchScope == PromotionBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  PromotionEntity copyWith({
    String? id,
    int? ownerProjectId,
    String? title,
    String? description,
    PromotionType? promotionType,
    PromotionDiscountType? discountType,
    double? discountValue,
    int? maxUses,
    int? usedCount,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? active,
    PromotionBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
  }) {
    return PromotionEntity(
      id: id ?? this.id,
      ownerProjectId: ownerProjectId ?? this.ownerProjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      promotionType: promotionType ?? this.promotionType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      active: active ?? this.active,
      branchScope: branchScope ?? this.branchScope,
      selectedBranchIds: selectedBranchIds ?? this.selectedBranchIds,
      selectedBranchNames: selectedBranchNames ?? this.selectedBranchNames,
    );
  }
}