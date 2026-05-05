import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

class ProductApiService {
  final ApiClient apiClient;

  ProductApiService(this.apiClient);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierProducts);

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => ProductModel.fromJson(
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

  Future<List<ProductModel>> searchProducts({
    required String query,
  }) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        return getProducts();
      }

      final response = await apiClient.dio.get(
        ApiConfig.supplierProductsSearch(trimmedQuery),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => ProductModel.fromJson(
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

  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierProducts,
        data: {
          'name': name.trim(),
          'description': description.trim(),
          'categoryId': int.tryParse(categoryId) ?? categoryId,
          'subCategoryId': subCategoryId == null
              ? null
              : int.tryParse(subCategoryId) ?? subCategoryId,
          'price': price,
          'minimumOrderQuantity': minimumOrderQuantity,
          'status': ProductModel.statusToJson(status),
          'imageUrl': imagePath,
        },
      );

      return ProductModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<ProductModel> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierProductById(productId),
        data: {
          'name': name.trim(),
          'description': description.trim(),
          'categoryId': int.tryParse(categoryId) ?? categoryId,
          'subCategoryId': subCategoryId == null
              ? null
              : int.tryParse(subCategoryId) ?? subCategoryId,
          'price': price,
          'minimumOrderQuantity': minimumOrderQuantity,
          'status': ProductModel.statusToJson(status),
          'imageUrl': imagePath,
        },
      );

      return ProductModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteProduct({
    required String productId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierProductById(productId),
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