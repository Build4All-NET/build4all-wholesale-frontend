import 'package:build4all_wholesale_frontend/core/network/api_client.dart';
import 'package:build4all_wholesale_frontend/core/network/api_config.dart';
import 'package:dio/dio.dart';

import '../models/order_payment_model.dart';

class SupplierPaymentApiService {
  final ApiClient _apiClient;

  SupplierPaymentApiService(this._apiClient);

  Future<OrderPaymentModel> getOrderPayment({
    required int orderId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.supplierOrderPayment(orderId),
      );

      return _mapOrderPaymentResponse(
        response.data,
        fallbackErrorMessage: 'Invalid supplier order payment response',
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  Future<OrderPaymentModel> markCashAsPaid({
    required int orderId,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.supplierOrderCashPaid(orderId),
      );

      return _mapOrderPaymentResponse(
        response.data,
        fallbackErrorMessage: 'Invalid mark cash payment as paid response',
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  OrderPaymentModel _mapOrderPaymentResponse(
    dynamic data, {
    required String fallbackErrorMessage,
  }) {
    if (data is Map<String, dynamic>) {
      return OrderPaymentModel.fromJson(data);
    }

    if (data is Map) {
      return OrderPaymentModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(fallbackErrorMessage);
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