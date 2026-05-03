import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';

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
  Future<void> addToCart({required HomeProductModel product}) async {
    try {
      await apiClient.dio.post(
        ApiConfig.retailerCartItems,
        data: {
          'productId': product.id,
          'productName': product.name,
          'imageUrl': product.imageUrl,
          'unitPrice': product.price,
          'currency': product.currency,
          'moq': product.moq,
          'moqUnit': product.moqUnit,
          'quantity': product.moq,
        },
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
