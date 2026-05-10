import 'package:equatable/equatable.dart';

enum ShippingMethodType {
  pickup,
  expressDelivery,
  standardDelivery,
}

extension ShippingMethodTypeX on ShippingMethodType {
  String get label {
    switch (this) {
      case ShippingMethodType.pickup:
        return 'Pickup from Branch';
      case ShippingMethodType.expressDelivery:
        return 'Express Delivery';
      case ShippingMethodType.standardDelivery:
        return 'Standard Delivery';
    }
  }

  String get backendValue {
    switch (this) {
      case ShippingMethodType.pickup:
        return 'PICKUP';
      case ShippingMethodType.expressDelivery:
        return 'EXPRESS_DELIVERY';
      case ShippingMethodType.standardDelivery:
        return 'STANDARD_DELIVERY';
    }
  }

  String get description {
    switch (this) {
      case ShippingMethodType.pickup:
        return 'Retailer picks up the order from an available supplier branch.';
      case ShippingMethodType.expressDelivery:
        return 'Faster delivery option, usually more expensive.';
      case ShippingMethodType.standardDelivery:
        return 'Normal delivery option, usually cheaper and slower.';
    }
  }

  static ShippingMethodType fromBackendValue(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case 'PICKUP':
        return ShippingMethodType.pickup;
      case 'EXPRESS_DELIVERY':
      case 'EXPRESS':
        return ShippingMethodType.expressDelivery;
      case 'STANDARD_DELIVERY':
      case 'DELIVERY':
      default:
        return ShippingMethodType.standardDelivery;
    }
  }
}

enum ShippingBranchScope {
  allBranches,
  selectedBranches,
}

extension ShippingBranchScopeX on ShippingBranchScope {
  String get label {
    switch (this) {
      case ShippingBranchScope.allBranches:
        return 'All Branches';
      case ShippingBranchScope.selectedBranches:
        return 'Selected Branches';
    }
  }
}

class ShippingMethodEntity extends Equatable {
  final String id;
  final String name;
  final ShippingMethodType methodType;

  final String? countryId;
  final String? countryName;
  final String? countryIso2Code;
  final String? countryIso3Code;

  final String? regionId;
  final String? regionName;
  final String? regionCode;

  final double cost;
  final String estimatedDeliveryTime;

  final double? minimumOrderAmount;
  final double? freeShippingThreshold;

  final ShippingBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;

  final bool active;
  final String? status;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ShippingMethodEntity({
    required this.id,
    required this.name,
    required this.methodType,
    this.countryId,
    this.countryName,
    this.countryIso2Code,
    this.countryIso3Code,
    this.regionId,
    this.regionName,
    this.regionCode,
    required this.cost,
    required this.estimatedDeliveryTime,
    this.minimumOrderAmount,
    this.freeShippingThreshold,
    required this.branchScope,
    this.selectedBranchIds = const [],
    this.selectedBranchNames = const [],
    required this.active,
    this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPickup => methodType == ShippingMethodType.pickup;

  String get methodTypeLabel => methodType.label;

  String get locationLabel {
    final country = countryName?.trim();
    final region = regionName?.trim();

    if (country != null &&
        country.isNotEmpty &&
        region != null &&
        region.isNotEmpty) {
      return '$country • $region';
    }

    if (country != null && country.isNotEmpty) {
      return country;
    }

    return 'No location selected';
  }

  String get branchScopeLabel {
    if (branchScope == ShippingBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  String get statusLabel {
    if (status != null && status!.trim().isNotEmpty) {
      final normalized = status!.trim().toUpperCase();

      if (normalized == 'ACTIVE') return 'Active';
      if (normalized == 'INACTIVE') return 'Inactive';
    }

    return active ? 'Active' : 'Inactive';
  }

  String get costLabel {
    if (isPickup) return 'Free pickup';
    return '\$${_cleanNumber(cost)}';
  }

  String get minimumOrderLabel {
    if (minimumOrderAmount == null) return 'No minimum';
    return '\$${_cleanNumber(minimumOrderAmount!)} minimum';
  }

  String get freeShippingLabel {
    if (isPickup) return 'Pickup only';
    if (freeShippingThreshold == null) return 'No free shipping';
    return 'Free above \$${_cleanNumber(freeShippingThreshold!)}';
  }

  ShippingMethodEntity copyWith({
    String? id,
    String? name,
    ShippingMethodType? methodType,
    String? countryId,
    String? countryName,
    String? countryIso2Code,
    String? countryIso3Code,
    String? regionId,
    String? regionName,
    String? regionCode,
    double? cost,
    String? estimatedDeliveryTime,
    double? minimumOrderAmount,
    double? freeShippingThreshold,
    ShippingBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
    bool? active,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShippingMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      methodType: methodType ?? this.methodType,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      countryIso2Code: countryIso2Code ?? this.countryIso2Code,
      countryIso3Code: countryIso3Code ?? this.countryIso3Code,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      regionCode: regionCode ?? this.regionCode,
      cost: cost ?? this.cost,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      branchScope: branchScope ?? this.branchScope,
      selectedBranchIds: selectedBranchIds ?? this.selectedBranchIds,
      selectedBranchNames: selectedBranchNames ?? this.selectedBranchNames,
      active: active ?? this.active,
      status: status ?? this.status,
      notes: notes ?? this.notes,
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

  @override
  List<Object?> get props => [
        id,
        name,
        methodType,
        countryId,
        countryName,
        countryIso2Code,
        countryIso3Code,
        regionId,
        regionName,
        regionCode,
        cost,
        estimatedDeliveryTime,
        minimumOrderAmount,
        freeShippingThreshold,
        branchScope,
        selectedBranchIds,
        selectedBranchNames,
        active,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}