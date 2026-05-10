import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/shipping_method_model.dart';

class ShippingMethodApiService {
  final ApiClient apiClient;

  ShippingMethodApiService(this.apiClient);

  Future<List<ShippingMethodModel>> getShippingMethods() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierShippingMethods,
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => ShippingMethodModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<ShippingMethodModel> createShippingMethod(
    ShippingMethodModel model,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierShippingMethods,
        data: model.toRequestJson(),
      );

      return ShippingMethodModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<ShippingMethodModel> updateShippingMethod(
    ShippingMethodModel model,
  ) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierShippingMethodById(model.id),
        data: model.toRequestJson(),
      );

      return ShippingMethodModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteShippingMethod(String id) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierShippingMethodById(id),
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