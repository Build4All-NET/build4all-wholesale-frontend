import '../entities/supplier_payment_method_entity.dart';

abstract class SupplierPaymentMethodRepository {
  Future<List<SupplierPaymentMethodEntity>> getPaymentMethods();

  Future<SupplierPaymentMethodEntity> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues,
  });

  Future<SupplierPaymentMethodEntity> testPaymentMethod(String methodCode);
}
