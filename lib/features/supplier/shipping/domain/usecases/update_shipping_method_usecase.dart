import '../entities/shipping_method_entity.dart';
import '../repositories/shipping_method_repository.dart';

class UpdateShippingMethodUseCase {
  final ShippingMethodRepository repository;

  UpdateShippingMethodUseCase(this.repository);

  Future<ShippingMethodEntity> call(ShippingMethodEntity method) {
    return repository.updateShippingMethod(method);
  }
}
