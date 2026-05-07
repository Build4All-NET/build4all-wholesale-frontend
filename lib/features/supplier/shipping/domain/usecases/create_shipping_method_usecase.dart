
import '../entities/shipping_method_entity.dart';
import '../repositories/shipping_method_repository.dart';

class CreateShippingMethodUseCase {
  final ShippingMethodRepository repository;

  CreateShippingMethodUseCase(this.repository);

  Future<ShippingMethodEntity> call(ShippingMethodEntity method) {
    return repository.createShippingMethod(method);
  }
}
