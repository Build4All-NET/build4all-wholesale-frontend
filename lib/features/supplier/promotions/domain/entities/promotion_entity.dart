import 'package:equatable/equatable.dart';

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

  String get backendValue {
    switch (this) {
      case PromotionDiscountType.percent:
        return 'PERCENT';
      case PromotionDiscountType.fixed:
        return 'FIXED';
      case PromotionDiscountType.freeShipping:
        return 'FREE_SHIPPING';
    }
  }

  static PromotionDiscountType fromBackend(String? value) {
    switch (value) {
      case 'FIXED':
        return PromotionDiscountType.fixed;
      case 'FREE_SHIPPING':
        return PromotionDiscountType.freeShipping;
      case 'PERCENT':
      default:
        return PromotionDiscountType.percent;
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

class PromotionEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final PromotionDiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool active;
  final PromotionBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;

  const PromotionEntity({
    required this.id,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startsAt,
    this.expiresAt,
    required this.active,
    this.branchScope = PromotionBranchScope.allBranches,
    this.selectedBranchIds = const [],
    this.selectedBranchNames = const [],
  });

  bool get started {
    if (startsAt == null) return true;
    return !DateTime.now().isBefore(startsAt!);
  }

  bool get expired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get currentlyValid {
    return active && started && !expired;
  }

  String get status {
    if (!active) return 'INACTIVE';
    if (!started) return 'SCHEDULED';
    if (expired) return 'EXPIRED';
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
      case 'ACTIVE':
      default:
        return 'Active';
    }
  }

  String get discountLabel {
    switch (discountType) {
      case PromotionDiscountType.percent:
        return '${cleanNumber(discountValue)}% Off';
      case PromotionDiscountType.fixed:
        return '\$${cleanNumber(discountValue)} Off';
      case PromotionDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }

  String get discountTypeLabel => discountType.label;

  String get branchApplicabilityLabel {
    if (branchScope == PromotionBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  String get branchScopeLabel {
    if (branchScope == PromotionBranchScope.allBranches) {
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

  String get validityLabel {
    if (startsAt == null && expiresAt == null) return 'No validity dates';

    final from = startsAt == null ? 'No start' : _formatShortDate(startsAt!);
    final to = expiresAt == null ? 'No end' : _formatShortDate(expiresAt!);

    return '$from → $to';
  }

  PromotionEntity copyWith({
    String? id,
    String? title,
    String? description,
    PromotionDiscountType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? active,
    PromotionBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
  }) {
    return PromotionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
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
        title,
        description,
        discountType,
        discountValue,
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