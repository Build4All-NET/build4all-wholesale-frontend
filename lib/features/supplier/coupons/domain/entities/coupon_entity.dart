import 'package:equatable/equatable.dart';

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

  String get backendValue {
    switch (this) {
      case CouponDiscountType.percent:
        return 'PERCENT';
      case CouponDiscountType.fixed:
        return 'FIXED';
      case CouponDiscountType.freeShipping:
        return 'FREE_SHIPPING';
    }
  }

  static CouponDiscountType fromBackend(String? value) {
    switch (value) {
      case 'FIXED':
        return CouponDiscountType.fixed;
      case 'FREE_SHIPPING':
        return CouponDiscountType.freeShipping;
      case 'PERCENT':
      default:
        return CouponDiscountType.percent;
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

class CouponEntity extends Equatable {
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
        return '${_cleanNumber(discountValue)}% Off';
      case CouponDiscountType.fixed:
        return '\$${_cleanNumber(discountValue)} Off';
      case CouponDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }

  String get discountTypeLabel {
    return discountType.label;
  }

  String get validityLabel {
    if (expiresAt == null) return 'No expiry date';
    return 'Expires: ${_formatShortDate(expiresAt!)}';
  }

  String get branchScopeLabel {
    if (branchScope == CouponBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'Selected Branches';
    }

    if (selectedBranchNames.length == 1) {
      return selectedBranchNames.first;
    }

    return '${selectedBranchNames.length} branches';
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

  String get usageLabel {
    if (maxUses == null) return 'Unlimited uses';
    return '$usedCount/$maxUses used';
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

  static String cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String _cleanNumber(double value) => cleanNumber(value);

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  List<Object?> get props => [
        id,
        ownerProjectId,
        code,
        description,
        discountType,
        discountValue,
        maxUses,
        usedCount,
        minOrderAmount,
        maxDiscountAmount,
        startsAt,
        expiresAt,
        active,
        branchScope,
        selectedBranchIds,
        selectedBranchNames,
      ];
}