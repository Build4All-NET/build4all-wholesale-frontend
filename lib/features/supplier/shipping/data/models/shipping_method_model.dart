import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodModel extends ShippingMethodEntity {
  const ShippingMethodModel({
    required super.id,
    required super.name,
    required super.methodType,
    super.countryId,
    super.countryName,
    super.countryIso2Code,
    super.countryIso3Code,
    super.regionId,
    super.regionName,
    super.regionCode,
    required super.cost,
    required super.estimatedDeliveryTime,
    super.minimumOrderAmount,
    super.freeShippingThreshold,
    required super.branchScope,
    super.selectedBranchIds,
    super.selectedBranchNames,
    required super.active,
    super.status,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShippingMethodModel.fromEntity(ShippingMethodEntity entity) {
    return ShippingMethodModel(
      id: entity.id,
      name: entity.name,
      methodType: entity.methodType,
      countryId: entity.countryId,
      countryName: entity.countryName,
      countryIso2Code: entity.countryIso2Code,
      countryIso3Code: entity.countryIso3Code,
      regionId: entity.regionId,
      regionName: entity.regionName,
      regionCode: entity.regionCode,
      cost: entity.cost,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      minimumOrderAmount: entity.minimumOrderAmount,
      freeShippingThreshold: entity.freeShippingThreshold,
      branchScope: entity.branchScope,
      selectedBranchIds: entity.selectedBranchIds,
      selectedBranchNames: entity.selectedBranchNames,
      active: entity.active,
      status: entity.status,
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

          if (id != null && id.trim().isNotEmpty) {
            selectedBranchIds.add(id);
          }

          if (name != null && name.trim().isNotEmpty) {
            selectedBranchNames.add(name);
          }
        }
      }
    }

    final appliesToAllBranches =
        json['appliesToAllBranches'] == null ||
            json['appliesToAllBranches'] == true;

    final countryName = _cleanText(json['countryName']) ??
        _cleanText(json['country']);

    final regionName = _cleanText(json['regionName']) ??
        _cleanText(json['region']);

    return ShippingMethodModel(
      id: json['id']?.toString() ?? '',
      name: _cleanText(json['methodName']) ?? '',
      methodType: ShippingMethodTypeX.fromBackendValue(
        json['methodType'] ?? json['deliveryType'],
      ),
      countryId: json['countryId']?.toString(),
      countryName: countryName,
      countryIso2Code: _cleanText(json['countryIso2Code']),
      countryIso3Code: _cleanText(json['countryIso3Code']),
      regionId: json['regionId']?.toString(),
      regionName: regionName,
      regionCode: _cleanText(json['regionCode']),
      cost: _doubleFromJson(json['shippingCost']) ?? 0,
      estimatedDeliveryTime:
          _cleanText(json['estimatedDeliveryTime']) ?? '',
      minimumOrderAmount: _doubleFromJson(json['minimumOrderAmount']),
      freeShippingThreshold: _doubleFromJson(json['freeShippingThreshold']),
      branchScope: appliesToAllBranches
          ? ShippingBranchScope.allBranches
          : ShippingBranchScope.selectedBranches,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      active: json['active'] != false,
      status: _cleanText(json['status']),
      notes: _cleanText(json['notes']),
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    final isPickup = methodType == ShippingMethodType.pickup;
    final appliesToAllBranches =
        branchScope == ShippingBranchScope.allBranches;

    return {
      'methodName': name.trim(),
      'methodType': methodType.backendValue,
      'countryId': int.tryParse(countryId ?? ''),
      'regionId': int.tryParse(regionId ?? ''),
      'shippingCost': isPickup ? 0 : cost,
      'estimatedDeliveryTime':
          isPickup ? 'Pickup from branch' : estimatedDeliveryTime.trim(),
      'minimumOrderAmount': minimumOrderAmount,
      'freeShippingThreshold': isPickup ? null : freeShippingThreshold,
      'appliesToAllBranches': appliesToAllBranches,
      'selectedBranchIds': appliesToAllBranches
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
      methodType: methodType,
      countryId: countryId,
      countryName: countryName,
      countryIso2Code: countryIso2Code,
      countryIso3Code: countryIso3Code,
      regionId: regionId,
      regionName: regionName,
      regionCode: regionCode,
      cost: cost,
      estimatedDeliveryTime: estimatedDeliveryTime,
      minimumOrderAmount: minimumOrderAmount,
      freeShippingThreshold: freeShippingThreshold,
      branchScope: branchScope,
      selectedBranchIds: selectedBranchIds,
      selectedBranchNames: selectedBranchNames,
      active: active,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _cleanText(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}