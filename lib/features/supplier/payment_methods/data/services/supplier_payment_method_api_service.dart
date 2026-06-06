import 'dart:convert';

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
      final response = await apiClient.dio.get(
        ApiConfig.supplierPaymentMethods,
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => SupplierPaymentMethodModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return <SupplierPaymentMethodModel>[];
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  Future<SupplierPaymentMethodModel> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues = const {},
  }) async {
    try {
      final normalizedMethodCode = methodCode.trim().toUpperCase();

      if (normalizedMethodCode.isEmpty) {
        throw AppException('Payment method code is missing.');
      }

      final response = await apiClient.dio.put(
        ApiConfig.supplierPaymentMethodByCode(normalizedMethodCode),
        data: {
          'enabled': enabled,
          'configJson': _encodeConfigJson(
            methodCode: normalizedMethodCode,
            configValues: configValues,
          ),
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return SupplierPaymentMethodModel.fromJson(data);
      }

      if (data is Map) {
        return SupplierPaymentMethodModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw AppException('Invalid payment method response.');
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  Future<SupplierPaymentMethodModel> testPaymentMethod(String methodCode) async {
    try {
      final normalizedMethodCode = methodCode.trim().toUpperCase();

      if (normalizedMethodCode.isEmpty) {
        throw AppException('Payment method code is missing.');
      }

      final response = await apiClient.dio.post(
        ApiConfig.supplierPaymentMethodTest(normalizedMethodCode),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return SupplierPaymentMethodModel.fromJson(data);
      }

      if (data is Map) {
        return SupplierPaymentMethodModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw AppException('Invalid payment method test response.');
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  String _encodeConfigJson({
    required String methodCode,
    required Map<String, dynamic> configValues,
  }) {
    if (configValues.isNotEmpty) {
      return jsonEncode(configValues);
    }

    if (methodCode == 'CASH') {
      return jsonEncode({
        'instructions': 'Pay cash on delivery.',
      });
    }

    return '{}';
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message != null) {
        return message.toString();
      }
    }

    if (data is Map) {
      final mappedData = Map<String, dynamic>.from(data);
      final message = mappedData['message'] ?? mappedData['error'];
      if (message != null) {
        return message.toString();
      }
    }

    return error.message ?? 'Payment request failed';
  }
}