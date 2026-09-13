import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/supplier_statistics_model.dart';

/// Reads the supplier's audience statistics from the project backend.
///
/// The endpoint is tenant-scoped server-side: the supplier's token decides
/// which app's retailers come back, so nothing here passes a project id.
class SupplierStatisticsApiService {
  final ApiClient apiClient;

  SupplierStatisticsApiService(this.apiClient);

  Future<SupplierStatisticsModel> getStatistics() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierStatistics);

      final data = response.data;

      if (data is Map) {
        return SupplierStatisticsModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      return SupplierStatisticsModel.fromJson(const <String, dynamic>{});
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
