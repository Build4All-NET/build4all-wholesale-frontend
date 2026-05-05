import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/branch_entity.dart';
import '../models/branch_model.dart';

class BranchApiService {
  final ApiClient apiClient;

  BranchApiService(this.apiClient);

  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierBranches);

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BranchModel.fromJson(
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

  Future<List<BranchModel>> searchBranches({
    required String query,
  }) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        return getBranches();
      }

      final response = await apiClient.dio.get(
        ApiConfig.supplierBranchesSearch(trimmedQuery),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BranchModel.fromJson(
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

  Future<BranchModel> createBranch({
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierBranches,
        data: {
          'name': name.trim(),
          'city': city.trim(),
          'address': address.trim(),
          'phoneNumber': phoneNumber.trim(),
          'status': _statusToJson(status),
        },
      );

      return BranchModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<BranchModel> updateBranch({
    required String branchId,
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierBranchById(branchId),
        data: {
          'name': name.trim(),
          'city': city.trim(),
          'address': address.trim(),
          'phoneNumber': phoneNumber.trim(),
          'status': _statusToJson(status),
        },
      );

      return BranchModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteBranch({
    required String branchId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierBranchById(branchId),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _statusToJson(BranchStatus status) {
    switch (status) {
      case BranchStatus.active:
        return 'ACTIVE';
      case BranchStatus.inactive:
        return 'INACTIVE';
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