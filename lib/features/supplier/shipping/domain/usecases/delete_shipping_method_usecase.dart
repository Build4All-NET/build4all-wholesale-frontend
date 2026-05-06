import '../repositories/shipping_method_repository.dart';

class DeleteShippingMethodUseCase {
  final ShippingMethodRepository repository;

  DeleteShippingMethodUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteShippingMethod(id);
  }
}
