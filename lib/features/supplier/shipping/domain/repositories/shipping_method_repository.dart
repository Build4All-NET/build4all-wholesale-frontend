import '../entities/shipping_method_entity.dart';

abstract class ShippingMethodRepository {
  Future<List<ShippingMethodEntity>> getShippingMethods();

  Future<ShippingMethodEntity> createShippingMethod(
    ShippingMethodEntity method,
  );

  Future<ShippingMethodEntity> updateShippingMethod(
    ShippingMethodEntity method,
  );

  Future<void> deleteShippingMethod(String id);
}