import '../../domain/entities/supplier_payment_method_entity.dart';
import '../../domain/repositories/supplier_payment_method_repository.dart';
import '../services/supplier_payment_method_api_service.dart';

class SupplierPaymentMethodRepositoryImpl implements SupplierPaymentMethodRepository {
  final SupplierPaymentMethodApiService apiService;

  SupplierPaymentMethodRepositoryImpl({required this.apiService});

  @override
  Future<List<SupplierPaymentMethodEntity>> getPaymentMethods() {
    return apiService.getPaymentMethods();
  }

  @override
  Future<SupplierPaymentMethodEntity> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues = const {},
  }) {
    return apiService.savePaymentMethod(
      methodCode: methodCode,
      enabled: enabled,
      configValues: configValues,
    );
  }

  @override
  Future<SupplierPaymentMethodEntity> testPaymentMethod(String methodCode) {
    return apiService.testPaymentMethod(methodCode);
  }
}
