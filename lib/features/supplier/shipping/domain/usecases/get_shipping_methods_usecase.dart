import '../entities/shipping_method_entity.dart';
import '../repositories/shipping_method_repository.dart';

class GetShippingMethodsUseCase {
  final ShippingMethodRepository repository;

  GetShippingMethodsUseCase(this.repository);

  Future<List<ShippingMethodEntity>> call() {
    return repository.getShippingMethods();
  }
}