import '../entities/supplier_payment_method_entity.dart';
import '../repositories/supplier_payment_method_repository.dart';

class SaveSupplierPaymentMethodUsecase {
  final SupplierPaymentMethodRepository repository;

  SaveSupplierPaymentMethodUsecase(this.repository);

  Future<SupplierPaymentMethodEntity> call({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues = const {},
  }) {
    return repository.savePaymentMethod(
      methodCode: methodCode,
      enabled: enabled,
      configValues: configValues,
    );
  }
}
