import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/supplier_payment_method_test_result_entity.dart';
import '../models/supplier_payment_method_model.dart';

class SupplierPaymentMethodApiService {
  final ApiClient apiClient;

  SupplierPaymentMethodApiService(this.apiClient);

  // ──────────────────────────────────────────── GET list ──

  Future<List<SupplierPaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierPaymentMethods,
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => SupplierPaymentMethodModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }

      return <SupplierPaymentMethodModel>[];
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  // ──────────────────────────────────────────── PUT save ──

  Future<SupplierPaymentMethodModel> savePaymentMethod({
    required String methodCode,
    required bool enabled,
    Map<String, dynamic> configValues = const {},
  }) async {
    try {
      final code = methodCode.trim().toUpperCase();

      if (code.isEmpty) throw AppException('Payment method code is missing.');

      final response = await apiClient.dio.put(
        ApiConfig.supplierPaymentMethodByCode(code),
        data: {
          'enabled': enabled,
          'configJson': _buildConfigJson(
            methodCode: code,
            configValues: configValues,
          ),
        },
      );

      return _parseModel(response.data,
          fallback: 'Invalid payment method response.');
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  // ──────────────────────────────────────────── POST test ──

  Future<SupplierPaymentMethodTestResultEntity> testPaymentMethod(
    String methodCode,
  ) async {
    try {
      final code = methodCode.trim().toUpperCase();

      if (code.isEmpty) throw AppException('Payment method code is missing.');

      final response = await apiClient.dio.post(
        ApiConfig.supplierPaymentMethodTest(code),
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      return SupplierPaymentMethodTestResultEntity(
        methodName: (data['methodName'] ?? code).toString(),
        success: data['success'] == true,
        message: (data['message'] ?? '').toString(),
      );
    } on DioException catch (error) {
      throw AppException(_extractMessage(error));
    }
  }

  // ──────────────────────────────────────────── helpers ──

  SupplierPaymentMethodModel _parseModel(
    dynamic data, {
    required String fallback,
  }) {
    if (data is Map<String, dynamic>) {
      return SupplierPaymentMethodModel.fromJson(data);
    }
    if (data is Map) {
      return SupplierPaymentMethodModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    throw AppException(fallback);
  }

  String _buildConfigJson({
    required String methodCode,
    required Map<String, dynamic> configValues,
  }) {
    if (configValues.isNotEmpty) {
      return jsonEncode(configValues);
    }

    if (methodCode == 'CASH') {
      return jsonEncode({'instructions': 'Pay cash on delivery.'});
    }

    return '{}';
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      final msg = mapped['message'] ?? mapped['error'];
      if (msg != null) return msg.toString();
    }

    return error.message ?? 'Payment request failed';
  }
}