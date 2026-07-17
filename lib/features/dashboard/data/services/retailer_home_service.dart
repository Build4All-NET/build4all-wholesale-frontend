import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/paged_result.dart';
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

  Future<PagedResult<HomeProductModel>> getFeaturedProducts({
    required int page,
    required int size,
    String? search,
    int? categoryId,
    int? subCategoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeFeaturedProducts,
        queryParameters: {
          'page': page,
          'size': size,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (categoryId != null) 'categoryId': categoryId,
          if (subCategoryId != null) 'subCategoryId': subCategoryId,
        },
      );

      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => HomeProductModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<PagedResult<HomeProductModel>> getProductsByCategory({
    required int categoryId,
    int? subCategoryId,
    String? search,
    required int page,
    required int size,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeCategoryProducts(categoryId),
        queryParameters: {
          'page': page,
          'size': size,
          if (subCategoryId != null) 'subCategoryId': subCategoryId,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => HomeProductModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<HomeProductModel> getProductById(int productId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeProductById(productId),
      );

      return HomeProductModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<PagedResult<HomeProductModel>> searchProducts(
    String query, {
    required int page,
    required int size,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeSearch,
        queryParameters: {'query': query, 'page': page, 'size': size},
      );

      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => HomeProductModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<PagedResult<HomeProductModel>> getPromotedProducts({
    required int page,
    required int size,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerPromotions,
        queryParameters: {'page': page, 'size': size},
      );

      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => HomeProductModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> addToCart({
    required HomeProductModel product,
    int? quantity,
  }) async {
    try {
      final safeQuantity = quantity ?? (product.moq <= 0 ? 1 : product.moq);

      await apiClient.dio.post(
        ApiConfig.retailerCartItems,
        data: {'productId': product.id, 'quantity': safeQuantity},
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
