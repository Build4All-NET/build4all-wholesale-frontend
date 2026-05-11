import 'package:equatable/equatable.dart';

enum PromotionDiscountType {
  percent,
  fixed,
}

extension PromotionDiscountTypeX on PromotionDiscountType {
  String get label {
    switch (this) {
      case PromotionDiscountType.percent:
        return 'Percent';
      case PromotionDiscountType.fixed:
        return 'Fixed Amount';
    }
  }

  String get backendValue {
    switch (this) {
      case PromotionDiscountType.percent:
        return 'PERCENT';
      case PromotionDiscountType.fixed:
        return 'FIXED';
    }
  }

  static PromotionDiscountType fromBackendValue(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case 'FIXED':
      case 'FIXED_AMOUNT':
        return PromotionDiscountType.fixed;
      case 'PERCENT':
      case 'PERCENTAGE':
      default:
        return PromotionDiscountType.percent;
    }
  }
}

enum PromotionTargetType {
  allProducts,
  product,
  category,
  subcategory,
}

extension PromotionTargetTypeX on PromotionTargetType {
  String get label {
    switch (this) {
      case PromotionTargetType.allProducts:
        return 'All Products';
      case PromotionTargetType.product:
        return 'Product';
      case PromotionTargetType.category:
        return 'Category';
      case PromotionTargetType.subcategory:
        return 'SubCategory';
    }
  }

  String get backendValue {
    switch (this) {
      case PromotionTargetType.allProducts:
        return 'ALL_PRODUCTS';
      case PromotionTargetType.product:
        return 'PRODUCT';
      case PromotionTargetType.category:
        return 'CATEGORY';
      case PromotionTargetType.subcategory:
        return 'SUBCATEGORY';
    }
  }

  static PromotionTargetType fromBackendValue(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case 'PRODUCT':
        return PromotionTargetType.product;
      case 'CATEGORY':
        return PromotionTargetType.category;
      case 'SUBCATEGORY':
      case 'SUB_CATEGORY':
        return PromotionTargetType.subcategory;
      case 'ALL_PRODUCTS':
      default:
        return PromotionTargetType.allProducts;
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

  final PromotionTargetType targetType;
  final String? targetId;
  final String? targetName;

  final double? minOrderAmount;
  final double? maxDiscountAmount;

  final DateTime? startDate;
  final DateTime? endDate;

  final bool active;
  final String? status;
  final bool currentlyValid;

  final PromotionBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PromotionEntity({
    required this.id,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.targetType = PromotionTargetType.allProducts,
    this.targetId,
    this.targetName,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startDate,
    this.endDate,
    required this.active,
    this.status,
    this.currentlyValid = false,
    required this.branchScope,
    this.selectedBranchIds = const [],
    this.selectedBranchNames = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPercent => discountType == PromotionDiscountType.percent;

  bool get targetsAllProducts => targetType == PromotionTargetType.allProducts;

  String get discountTypeLabel => discountType.label;

  String get discountLabel {
    if (discountType == PromotionDiscountType.percent) {
      return '${_cleanNumber(discountValue)}% off';
    }

    return '\$${_cleanNumber(discountValue)} off';
  }

  String get targetLabel {
    if (targetType == PromotionTargetType.allProducts) {
      return 'All Products';
    }

    final safeName = targetName?.trim();

    if (safeName != null && safeName.isNotEmpty) {
      return '${targetType.label}: $safeName';
    }

    return targetType.label;
  }

  String get statusLabel {
    if (status != null && status!.trim().isNotEmpty) {
      final normalized = status!.trim().toUpperCase();

      switch (normalized) {
        case 'ACTIVE':
          return 'Active';
        case 'INACTIVE':
          return 'Inactive';
        case 'SCHEDULED':
          return 'Scheduled';
        case 'EXPIRED':
          return 'Expired';
      }
    }

    return active ? 'Active' : 'Inactive';
  }

  String get branchScopeLabel {
    if (branchScope == PromotionBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  String get validityLabel {
    final start = _dateLabel(startDate);
    final end = _dateLabel(endDate);

    if (start == null && end == null) {
      return 'No date limit';
    }

    if (start != null && end != null) {
      return '$start → $end';
    }

    if (start != null) {
      return 'Starts $start';
    }

    return 'Ends $end';
  }

  String get minOrderLabel {
    if (minOrderAmount == null) return 'No minimum';
    return '\$${_cleanNumber(minOrderAmount!)} minimum';
  }

  String get maxDiscountLabel {
    if (!isPercent) return 'Not applicable';
    if (maxDiscountAmount == null) return 'No max limit';
    return 'Max \$${_cleanNumber(maxDiscountAmount!)}';
  }

  PromotionEntity copyWith({
    String? id,
    String? title,
    String? description,
    PromotionDiscountType? discountType,
    double? discountValue,
    PromotionTargetType? targetType,
    String? targetId,
    String? targetName,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    String? status,
    bool? currentlyValid,
    PromotionBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromotionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      status: status ?? this.status,
      currentlyValid: currentlyValid ?? this.currentlyValid,
      branchScope: branchScope ?? this.branchScope,
      selectedBranchIds: selectedBranchIds ?? this.selectedBranchIds,
      selectedBranchNames: selectedBranchNames ?? this.selectedBranchNames,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String? _dateLabel(DateTime? value) {
    if (value == null) return null;

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        discountType,
        discountValue,
        targetType,
        targetId,
        targetName,
        minOrderAmount,
        maxDiscountAmount,
        startDate,
        endDate,
        active,
        status,
        currentlyValid,
        branchScope,
        selectedBranchIds,
        selectedBranchNames,
        createdAt,
        updatedAt,
      ];
}