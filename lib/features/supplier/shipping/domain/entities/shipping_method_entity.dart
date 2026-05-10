import 'package:equatable/equatable.dart';

enum ShippingDeliveryType {
  delivery,
  pickup,
  expressDelivery,
  standardDelivery,
}

extension ShippingDeliveryTypeX on ShippingDeliveryType {
  String get label {
    switch (this) {
      case ShippingDeliveryType.delivery:
        return 'Delivery';
      case ShippingDeliveryType.pickup:
        return 'Pickup';
      case ShippingDeliveryType.expressDelivery:
        return 'Express Delivery';
      case ShippingDeliveryType.standardDelivery:
        return 'Standard Delivery';
    }
  }

  String get backendValue {
    switch (this) {
      case ShippingDeliveryType.delivery:
        return 'DELIVERY';
      case ShippingDeliveryType.pickup:
        return 'PICKUP';
      case ShippingDeliveryType.expressDelivery:
        return 'EXPRESS_DELIVERY';
      case ShippingDeliveryType.standardDelivery:
        return 'STANDARD_DELIVERY';
    }
  }

  static ShippingDeliveryType fromBackendValue(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case 'PICKUP':
        return ShippingDeliveryType.pickup;
      case 'EXPRESS_DELIVERY':
        return ShippingDeliveryType.expressDelivery;
      case 'STANDARD_DELIVERY':
        return ShippingDeliveryType.standardDelivery;
      case 'DELIVERY':
      default:
        return ShippingDeliveryType.delivery;
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
  final ShippingDeliveryType deliveryType;
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
    required this.deliveryType,
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

  bool get isPickup => deliveryType == ShippingDeliveryType.pickup;

  String get statusLabel => active ? 'Active' : 'Inactive';

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
    ShippingDeliveryType? deliveryType,
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
      deliveryType: deliveryType ?? this.deliveryType,
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
        deliveryType,
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