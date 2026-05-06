import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodModel extends ShippingMethodEntity {
  const ShippingMethodModel({
    required super.id,
    required super.name,
    required super.deliveryType,
    required super.cost,
    required super.estimatedDeliveryTime,
    super.minimumOrderAmount,
    super.freeShippingThreshold,
    required super.branchScope,
    super.selectedBranchIds,
    super.selectedBranchNames,
    required super.active,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShippingMethodModel.fromEntity(ShippingMethodEntity entity) {
    return ShippingMethodModel(
      id: entity.id,
      name: entity.name,
      deliveryType: entity.deliveryType,
      cost: entity.cost,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      minimumOrderAmount: entity.minimumOrderAmount,
      freeShippingThreshold: entity.freeShippingThreshold,
      branchScope: entity.branchScope,
      selectedBranchIds: entity.selectedBranchIds,
      selectedBranchNames: entity.selectedBranchNames,
      active: entity.active,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    final selectedBranchIds = <String>[];
    final selectedBranchNames = <String>[];

    final selectedBranches = json['selectedBranches'];
    if (selectedBranches is List) {
      for (final item in selectedBranches) {
        if (item is Map) {
          final branch = Map<String, dynamic>.from(item);
          final id = branch['id']?.toString();
          final name = branch['name']?.toString();

          if (id != null && id.isNotEmpty) {
            selectedBranchIds.add(id);
          }

          if (name != null && name.isNotEmpty) {
            selectedBranchNames.add(name);
          }
        }
      }
    }

    final appliesToAllBranches =
        json['appliesToAllBranches'] == null ||
            json['appliesToAllBranches'] == true;

    return ShippingMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['methodName']?.toString() ?? '',
      deliveryType:
          ShippingDeliveryTypeX.fromBackendValue(json['deliveryType']),
      cost: _doubleFromJson(json['shippingCost']) ?? 0,
      estimatedDeliveryTime:
          json['estimatedDeliveryTime']?.toString() ?? '',
      minimumOrderAmount: _doubleFromJson(json['minimumOrderAmount']),
      freeShippingThreshold: _doubleFromJson(json['freeShippingThreshold']),
      branchScope: appliesToAllBranches
          ? ShippingBranchScope.allBranches
          : ShippingBranchScope.selectedBranches,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      active: json['active'] != false,
      notes: json['notes']?.toString(),
      createdAt: _dateFromJson(json['createdAt']),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toRequestJson() {
    final isPickup = deliveryType == ShippingDeliveryType.pickup;

    return {
      'methodName': name.trim(),
      'deliveryType': deliveryType.backendValue,
      'shippingCost': isPickup ? 0 : cost,
      'estimatedDeliveryTime':
          isPickup ? 'Pickup from branch' : estimatedDeliveryTime.trim(),
      'minimumOrderAmount': minimumOrderAmount,
      'freeShippingThreshold': isPickup ? null : freeShippingThreshold,
      'appliesToAllBranches':
          branchScope == ShippingBranchScope.allBranches,
      'selectedBranchIds': branchScope == ShippingBranchScope.allBranches
          ? <int>[]
          : selectedBranchIds
              .map((id) => int.tryParse(id))
              .whereType<int>()
              .toList(),
      'active': active,
      'notes': notes == null || notes!.trim().isEmpty ? null : notes!.trim(),
    };
  }

  ShippingMethodEntity toEntity() {
    return ShippingMethodEntity(
      id: id,
      name: name,
      deliveryType: deliveryType,
      cost: cost,
      estimatedDeliveryTime: estimatedDeliveryTime,
      minimumOrderAmount: minimumOrderAmount,
      freeShippingThreshold: freeShippingThreshold,
      branchScope: branchScope,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      active: active,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime _dateFromJson(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}