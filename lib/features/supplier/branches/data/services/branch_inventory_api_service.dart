import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/branch_inventory_model.dart';

class BranchInventoryApiService {
  final ApiClient apiClient;

  BranchInventoryApiService(this.apiClient);

  Future<List<BranchInventoryModel>> getInventoryByBranch({
    required String branchId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierInventoryByBranch(branchId),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BranchInventoryModel.fromJson(
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

  Future<BranchInventoryModel> assignProductToBranch({
    required String branchId,
    required String productId,
    required int stockQuantity,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierBranchInventory,
        data: {
          'branchId': int.tryParse(branchId) ?? branchId,
          'productId': int.tryParse(productId) ?? productId,
          'stockQuantity': stockQuantity,
        },
      );

      return BranchInventoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<BranchInventoryModel> updateStock({
    required String inventoryId,
    required int stockQuantity,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierInventoryStockById(inventoryId),
        data: {
          'stockQuantity': stockQuantity,
        },
      );

      return BranchInventoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
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
        ApiConfig.supplierInventoryById(inventoryId),
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