import '../entities/supplier_payment_method_test_result_entity.dart';
import '../repositories/supplier_payment_method_repository.dart';

class TestSupplierPaymentMethodUsecase {
  final SupplierPaymentMethodRepository repository;

  const TestSupplierPaymentMethodUsecase(this.repository);

  Future<SupplierPaymentMethodTestResultEntity> call({
    required String methodCode,
  }) {
    return repository.testPaymentMethod(methodCode: methodCode);
  }
}