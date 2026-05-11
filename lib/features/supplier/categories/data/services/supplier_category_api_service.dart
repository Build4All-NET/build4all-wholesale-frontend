import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/supplier_category_entity.dart';
import '../models/supplier_category_model.dart';
import '../models/supplier_sub_category_model.dart';

class SupplierCategoryApiService {
  final ApiClient apiClient;

  SupplierCategoryApiService(this.apiClient);

  Future<List<SupplierCategoryModel>> getCategories() async {
    return _getCategoryList(ApiConfig.supplierCategories);
  }

  Future<List<SupplierCategoryModel>> getAllCategories() async {
    return _getCategoryList(ApiConfig.supplierCategoriesAll);
  }

  Future<List<SupplierCategoryModel>> _getCategoryList(String path) async {
    try {
      final response = await apiClient.dio.get(path);
      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => SupplierCategoryModel.fromJson(
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

  Future<SupplierCategoryModel> createCategory({
    required String name,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierCategories,
        data: {'name': name.trim()},
      );

      return SupplierCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierCategoryModel> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierCategoryById(categoryId),
        data: {'name': name.trim()},
      );

      return SupplierCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierCategoryModel> updateCategoryStatus({
    required String categoryId,
    required SupplierCatalogStatus status,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierCategoryStatus(
          categoryId,
          status == SupplierCatalogStatus.active ? 'ACTIVE' : 'INACTIVE',
        ),
      );

      return SupplierCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierCategoryById(categoryId),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<SupplierSubCategoryModel>> getSubCategories() async {
    return _getSubCategoryList(ApiConfig.supplierSubCategories);
  }

  Future<List<SupplierSubCategoryModel>> getAllSubCategories() async {
    return _getSubCategoryList(ApiConfig.supplierSubCategoriesAll);
  }

  Future<List<SupplierSubCategoryModel>> _getSubCategoryList(String path) async {
    try {
      final response = await apiClient.dio.get(path);
      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => SupplierSubCategoryModel.fromJson(
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

  Future<List<SupplierSubCategoryModel>> getSubCategoriesByCategory({
    required String categoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierSubCategoriesByCategory(categoryId),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => SupplierSubCategoryModel.fromJson(
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

  Future<SupplierSubCategoryModel> createSubCategory({
    required String categoryId,
    required String name,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierSubCategories,
        data: {
          'categoryId': int.tryParse(categoryId) ?? categoryId,
          'name': name.trim(),
        },
      );

      return SupplierSubCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierSubCategoryModel> updateSubCategory({
    required String subCategoryId,
    required String name,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierSubCategoryById(subCategoryId),
        data: {'name': name.trim()},
      );

      return SupplierSubCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierSubCategoryModel> updateSubCategoryStatus({
    required String subCategoryId,
    required SupplierCatalogStatus status,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierSubCategoryStatus(
          subCategoryId,
          status == SupplierCatalogStatus.active ? 'ACTIVE' : 'INACTIVE',
        ),
      );

      return SupplierSubCategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteSubCategory({
    required String subCategoryId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierSubCategoryById(subCategoryId),
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
