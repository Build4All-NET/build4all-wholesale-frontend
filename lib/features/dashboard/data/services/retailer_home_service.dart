import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/retailer_home_model.dart';

class RetailerHomeService {
  final ApiClient apiClient;

  RetailerHomeService(this.apiClient);

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

  Future<List<HomeProductModel>> getProductsByCategory({
    required int categoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeCategoryProducts(categoryId),
      );

      return (response.data as List<dynamic>? ?? [])
          .map(
            (item) => HomeProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> addToCart({required HomeProductModel product}) async {
    try {
      final quantity = product.moq <= 0 ? 1 : product.moq;

      await apiClient.dio.post(
        ApiConfig.retailerCartItems,
        data: {'productId': product.id, 'quantity': quantity},
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
