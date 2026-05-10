import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/promotion_model.dart';

class PromotionApiService {
  final ApiClient apiClient;

  PromotionApiService(this.apiClient);

  Future<List<PromotionModel>> getPromotions() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierPromotions,
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => PromotionModel.fromJson(
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

  Future<PromotionModel> createPromotion(PromotionModel model) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierPromotions,
        data: model.toRequestJson(),
      );

      return PromotionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<PromotionModel> updatePromotion(PromotionModel model) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierPromotionById(model.id),
        data: model.toRequestJson(),
      );

      return PromotionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierPromotionById(id),
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