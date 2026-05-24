import '../entities/supplier_payment_method_entity.dart';
import '../repositories/supplier_payment_method_repository.dart';

class GetSupplierPaymentMethodsUsecase {
  final SupplierPaymentMethodRepository repository;

  GetSupplierPaymentMethodsUsecase(this.repository);

  Future<List<SupplierPaymentMethodEntity>> call() {
    return repository.getPaymentMethods();
  }
}
