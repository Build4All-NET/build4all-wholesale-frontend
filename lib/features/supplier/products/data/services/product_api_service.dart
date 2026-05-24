import 'dart:io';

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
      final imageUrl = await _resolveProductImageUrl(imagePath);

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
          'imageUrl': imageUrl,
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
    String? existingImageUrl,
  }) async {
    try {
      final resolvedImageUrl = await _resolveProductImageUrl(imagePath);

      // Important:
      // If the supplier edits a product without selecting a new image,
      // keep the old imageUrl instead of sending null and deleting the image.
      final imageUrl = resolvedImageUrl ?? _normalizeExistingImageUrl(existingImageUrl);

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
          'imageUrl': imageUrl,
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

  Future<String?> _resolveProductImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final normalized = imagePath.trim();

    if (normalized.startsWith('/uploadsPublic/')) {
      return normalized;
    }

    if (normalized.contains('/uploadsPublic/')) {
      return normalized.substring(
        normalized.indexOf('/uploadsPublic/'),
      );
    }

    final file = File(normalized);

    if (!file.existsSync()) {
      return null;
    }

    return _uploadProductImage(file);
  }

  String? _normalizeExistingImageUrl(String? existingImageUrl) {
    if (existingImageUrl == null || existingImageUrl.trim().isEmpty) {
      return null;
    }

    final normalized = existingImageUrl.trim();

    if (normalized.startsWith('/uploadsPublic/')) {
      return normalized;
    }

    if (normalized.contains('/uploadsPublic/')) {
      return normalized.substring(
        normalized.indexOf('/uploadsPublic/'),
      );
    }

    return normalized;
  }

  Future<String> _uploadProductImage(File file) async {
    try {
      final filename = _extractFilename(file.path);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
      });

      final response = await apiClient.dio.post(
        ApiConfig.supplierProductImageUpload,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;

      if (data is Map && data['imageUrl'] != null) {
        return data['imageUrl'].toString();
      }

      throw AppException('Image upload failed');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _extractFilename(String filePath) {
    final parts = filePath.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? 'product_image.jpg' : parts.last;
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