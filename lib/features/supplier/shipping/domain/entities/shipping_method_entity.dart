import 'package:equatable/equatable.dart';

enum ShippingMethodType {
  standardDelivery,
  expressDelivery,
  pickup,
}

extension ShippingMethodTypeX on ShippingMethodType {
  String get label {
    switch (this) {
      case ShippingMethodType.standardDelivery:
        return 'Standard Delivery';
      case ShippingMethodType.expressDelivery:
        return 'Express Delivery';
      case ShippingMethodType.pickup:
        return 'Pickup from Branch';
    }
  }

  String get backendValue {
    switch (this) {
      case ShippingMethodType.standardDelivery:
        return 'STANDARD_DELIVERY';
      case ShippingMethodType.expressDelivery:
        return 'EXPRESS_DELIVERY';
      case ShippingMethodType.pickup:
        return 'PICKUP';
    }
  }

  static ShippingMethodType fromBackendValue(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case 'EXPRESS_DELIVERY':
        return ShippingMethodType.expressDelivery;
      case 'PICKUP':
        return ShippingMethodType.pickup;
      case 'STANDARD_DELIVERY':
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

class ShippingMethodLocation {
  static const String lebanon = 'Lebanon';

  static const List<String> lebanonRegions = [
    'Beirut',
    'Mount Lebanon',
    'North Lebanon',
    'Akkar',
    'Baalbek-Hermel',
    'Bekaa',
    'South Lebanon',
    'Nabatieh',
  ];
}

class ShippingMethodEntity extends Equatable {
  final String id;
  final String name;
  final ShippingMethodType methodType;
  final String country;
  final String region;
  final double cost;
  final String estimatedDeliveryTime;
  final double? minimumOrderAmount;
  final double? freeShippingThreshold;
  final ShippingBranchScope branchScope;
  final List<String> selectedBranchIds;
  final List<String> selectedBranchNames;
  final bool active;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShippingMethodEntity({
    required this.id,
    required this.name,
    required this.methodType,
    required this.country,
    required this.region,
    required this.cost,
    required this.estimatedDeliveryTime,
    this.minimumOrderAmount,
    this.freeShippingThreshold,
    required this.branchScope,
    this.selectedBranchIds = const [],
    this.selectedBranchNames = const [],
    required this.active,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPickup => methodType == ShippingMethodType.pickup;

  String get statusLabel => active ? 'Active' : 'Inactive';

  String get locationLabel => '$country • $region';

  String get costLabel {
    if (cost == 0) return 'Free';
    return '\$${_cleanNumber(cost)}';
  }

  String get minimumOrderLabel {
    if (minimumOrderAmount == null) return 'No minimum';
    return '\$${_cleanNumber(minimumOrderAmount!)} minimum';
  }

  String get freeShippingThresholdLabel {
    if (isPickup) return 'Not applicable for pickup';
    if (freeShippingThreshold == null) return 'No free threshold';
    return 'Free above \$${_cleanNumber(freeShippingThreshold!)}';
  }

  String get branchApplicabilityLabel {
    if (branchScope == ShippingBranchScope.allBranches) {
      return 'All Branches';
    }

    if (selectedBranchNames.isEmpty) {
      return 'No branches selected';
    }

    return selectedBranchNames.join(', ');
  }

  String get branchShortLabel => branchApplicabilityLabel;

  ShippingMethodEntity copyWith({
    String? id,
    String? name,
    ShippingMethodType? methodType,
    String? country,
    String? region,
    double? cost,
    String? estimatedDeliveryTime,
    double? minimumOrderAmount,
    double? freeShippingThreshold,
    ShippingBranchScope? branchScope,
    List<String>? selectedBranchIds,
    List<String>? selectedBranchNames,
    bool? active,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShippingMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      methodType: methodType ?? this.methodType,
      country: country ?? this.country,
      region: region ?? this.region,
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
        country,
        region,
        cost,
        estimatedDeliveryTime,
        minimumOrderAmount,
        freeShippingThreshold,
        branchScope,
        selectedBranchIds,
        selectedBranchNames,
        active,
        notes,
        createdAt,
        updatedAt,
      ];
}