import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/supplier_payment_method_model.dart';

class SupplierPaymentMethodApiService {
  final ApiClient apiClient;

  SupplierPaymentMethodApiService(this.apiClient);

  Future<List<SupplierPaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierPaymentMethods);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => SupplierPaymentMethodModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierPaymentMethodModel> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues = const {},
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierPaymentMethodByCode(methodCode),
        data: {
          'enabled': enabled,
          'configValues': configValues,
        },
      );
      return SupplierPaymentMethodModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierPaymentMethodModel> testPaymentMethod(String methodCode) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierPaymentMethodTest(methodCode),
      );
      return SupplierPaymentMethodModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return e.message ?? 'Something went wrong';
  }
}
