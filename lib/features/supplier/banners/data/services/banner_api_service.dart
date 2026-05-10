import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/banner_model.dart';

class BannerApiService {
  final ApiClient apiClient;

  BannerApiService(this.apiClient);

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierBanners);
      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => BannerModel.fromBackendJson(
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

  Future<BannerModel> createBanner(BannerModel banner) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierBanners,
        data: banner.toBackendCreateJson(),
      );

      return BannerModel.fromBackendJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<BannerModel> updateBanner(BannerModel banner) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierBannerById(banner.id),
        data: banner.toBackendCreateJson(),
      );

      return BannerModel.fromBackendJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierBannerById(bannerId),
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