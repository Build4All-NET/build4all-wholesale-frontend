import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../auth/data/models/api_response_model.dart';
import '../models/retailer_home_model.dart';

class RetailerHomeService {
  final ApiClient apiClient;

  RetailerHomeService(this.apiClient);

  /// Loads all data needed by Retailer Home from one backend endpoint.
  Future<RetailerHomeModel> getHome() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.retailerHome);

      return RetailerHomeModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// Adds selected product using backend MOQ logic.
  Future<ApiResponseModel> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerHomeAddCartItem,
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      return ApiResponseModel.fromJson(
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