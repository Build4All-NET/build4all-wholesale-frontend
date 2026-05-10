import '../models/shipping_method_model.dart';
import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodMockService {
  static final List<ShippingMethodModel> _methods = [
    ShippingMethodModel(
      id: '1',
      name: 'Standard Delivery',
      deliveryType: ShippingDeliveryType.standardDelivery,
      cost: 5,
      estimatedDeliveryTime: '2-3 business days',
      minimumOrderAmount: 50,
      freeShippingThreshold: 150,
      branchScope: ShippingBranchScope.allBranches,
      selectedBranchIds: const [],
      selectedBranchNames: const [],
      active: true,
      notes: 'Default mock standard delivery',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ShippingMethodModel(
      id: '2',
      name: 'Pickup from Branch',
      deliveryType: ShippingDeliveryType.pickup,
      cost: 0,
      estimatedDeliveryTime: 'Pickup from branch',
      minimumOrderAmount: 0,
      freeShippingThreshold: null,
      branchScope: ShippingBranchScope.selectedBranches,
      selectedBranchIds: const ['1'],
      selectedBranchNames: const ['Main Branch'],
      active: true,
      notes: 'Default mock pickup option',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<ShippingMethodModel>> getShippingMethods() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return List<ShippingMethodModel>.from(_methods);
  }

  Future<ShippingMethodModel> createShippingMethod(
    ShippingMethodModel method,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now();

    final created = ShippingMethodModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: method.name,
      deliveryType: method.deliveryType,
      cost: method.deliveryType == ShippingDeliveryType.pickup ? 0 : method.cost,
      estimatedDeliveryTime: method.deliveryType == ShippingDeliveryType.pickup
          ? 'Pickup from branch'
          : method.estimatedDeliveryTime,
      minimumOrderAmount: method.minimumOrderAmount,
      freeShippingThreshold: method.deliveryType == ShippingDeliveryType.pickup
          ? null
          : method.freeShippingThreshold,
      branchScope: method.branchScope,
      selectedBranchIds: method.selectedBranchIds,
      selectedBranchNames: method.selectedBranchNames,
      active: method.active,
      notes: method.notes,
      createdAt: now,
      updatedAt: now,
    );

    _methods.insert(0, created);

    return created;
  }

  Future<ShippingMethodModel> updateShippingMethod(
    ShippingMethodModel method,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _methods.indexWhere((item) => item.id == method.id);

    if (index == -1) {
      throw Exception('Shipping method not found');
    }

    final oldMethod = _methods[index];

    final updated = ShippingMethodModel(
      id: oldMethod.id,
      name: method.name,
      deliveryType: method.deliveryType,
      cost: method.deliveryType == ShippingDeliveryType.pickup ? 0 : method.cost,
      estimatedDeliveryTime: method.deliveryType == ShippingDeliveryType.pickup
          ? 'Pickup from branch'
          : method.estimatedDeliveryTime,
      minimumOrderAmount: method.minimumOrderAmount,
      freeShippingThreshold: method.deliveryType == ShippingDeliveryType.pickup
          ? null
          : method.freeShippingThreshold,
      branchScope: method.branchScope,
      selectedBranchIds: method.selectedBranchIds,
      selectedBranchNames: method.selectedBranchNames,
      active: method.active,
      notes: method.notes,
      createdAt: oldMethod.createdAt,
      updatedAt: DateTime.now(),
    );

    _methods[index] = updated;

    return updated;
  }

  Future<void> deleteShippingMethod(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    _methods.removeWhere((method) => method.id == id);
  }
}