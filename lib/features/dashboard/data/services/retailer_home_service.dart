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

  Future<HomeProductPageModel> getProducts({
    required int page,
    int size = 20,
    String? search,
    int? categoryId,
    int? subCategoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeProducts,
        queryParameters: _productQueryParameters(
          page: page,
          size: size,
          search: search,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
        ),
      );

      return HomeProductPageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<HomeProductPageModel> getProductsByCategory({
    required int categoryId,
    required int page,
    int size = 20,
    String? search,
    int? subCategoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeCategoryProducts(categoryId),
        queryParameters: _productQueryParameters(
          page: page,
          size: size,
          search: search,
          subCategoryId: subCategoryId,
        ),
      );

      return HomeProductPageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<HomeProductPageModel> searchProducts({
    required String query,
    required int page,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerHomeSearch,
        queryParameters: {'query': query, 'page': page, 'size': size},
      );

      return HomeProductPageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<HomeProductPageModel> getPromotedProducts({
    required int page,
    int size = 20,
    String? search,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerPromotions,
        queryParameters: _productQueryParameters(
          page: page,
          size: size,
          search: search,
        ),
      );

      return HomeProductPageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<HomeProductPageModel> getBannerTargetProducts({
    required HomeBannerModel banner,
    required int page,
    int size = 20,
    String? search,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerBannerTargetProducts,
        queryParameters: {
          'targetType': banner.targetType,
          if (banner.targetValue != null) 'targetValue': banner.targetValue,
          'page': page,
          'size': size,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      return HomeProductPageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
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

  Map<String, dynamic> _productQueryParameters({
    required int page,
    required int size,
    String? search,
    int? categoryId,
    int? subCategoryId,
  }) {
    return {
      'page': page,
      'size': size,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (categoryId != null) 'categoryId': categoryId,
      if (subCategoryId != null) 'subCategoryId': subCategoryId,
    };
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
