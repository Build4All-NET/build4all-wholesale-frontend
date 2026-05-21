import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/retailer_order_model.dart';

class RetailerOrderApiService {
  final ApiClient apiClient;

  RetailerOrderApiService(this.apiClient);

  Future<List<RetailerOrderModel>> getOrders() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.retailerOrders);
      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => RetailerOrderModel.fromJson(
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

  Future<RetailerOrderModel> getOrderDetails({required int orderId}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerOrderById(orderId.toString()),
      );

      return RetailerOrderModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerOrderModel> cancelOrder({required int orderId}) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.retailerOrderCancel(orderId.toString()),
      );

      return RetailerOrderModel.fromJson(
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
