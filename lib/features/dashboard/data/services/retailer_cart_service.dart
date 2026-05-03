import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/retailer_cart_model.dart';
import '../models/retailer_home_model.dart';

class RetailerCartService {
  final ApiClient projectApiClient;

  RetailerCartService({required this.projectApiClient});

  Future<RetailerCartModel> getCart() async {
    try {
      final response = await projectApiClient.dio.get(ApiConfig.retailerCart);

      return RetailerCartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCartModel> addProductToCart({
    required HomeProductModel product,
  }) async {
    try {
      final response = await projectApiClient.dio.post(
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

      return RetailerCartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCartModel> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await projectApiClient.dio.put(
        ApiConfig.retailerCartItemById(cartItemId),
        data: {'quantity': quantity},
      );

      return RetailerCartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCartModel> deleteItem({required int cartItemId}) async {
    try {
      final response = await projectApiClient.dio.delete(
        ApiConfig.retailerCartItemById(cartItemId),
      );

      return RetailerCartModel.fromJson(
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
