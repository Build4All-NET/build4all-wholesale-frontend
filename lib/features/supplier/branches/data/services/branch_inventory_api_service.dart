import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../models/branch_inventory_item_model.dart';

class BranchInventoryApiService {
  final ApiClient apiClient;

  BranchInventoryApiService(this.apiClient);

  Future<List<BranchInventoryItemModel>> getInventoryByBranch({
    required String branchId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/supplier/branch-inventory/branch/$branchId',
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BranchInventoryItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<BranchInventoryItemModel>> getInventoryByProduct({
    required String productId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/supplier/branch-inventory/product/$productId',
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BranchInventoryItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<BranchInventoryItemModel> assignProductToBranch({
    required String branchId,
    required String productId,
    required int stockQuantity,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/supplier/branch-inventory',
        data: {
          'branchId': int.parse(branchId),
          'productId': int.parse(productId),
          'stockQuantity': stockQuantity,
        },
      );

      return BranchInventoryItemModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<BranchInventoryItemModel> updateStock({
    required String inventoryId,
    required int stockQuantity,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/supplier/branch-inventory/$inventoryId/stock',
        data: {
          'stockQuantity': stockQuantity,
        },
      );

      return BranchInventoryItemModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteInventoryItem({
    required String inventoryId,
  }) async {
    try {
      await apiClient.dio.delete(
        '/supplier/branch-inventory/$inventoryId',
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
