import '../entities/supplier_payment_method_entity.dart';
import '../entities/supplier_payment_method_test_result_entity.dart';

abstract class SupplierPaymentMethodRepository {
  Future<List<SupplierPaymentMethodEntity>> getPaymentMethods();

  Future<SupplierPaymentMethodEntity> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues,
  });

  Future<SupplierPaymentMethodTestResultEntity> testPaymentMethod({
    required String methodCode,
  });
}