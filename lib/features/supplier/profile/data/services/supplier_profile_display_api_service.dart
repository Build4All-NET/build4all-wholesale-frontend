import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/supplier_profile_display_model.dart';

class SupplierProfileDisplayApiService {
  final ApiClient apiClient;

  SupplierProfileDisplayApiService(this.apiClient);

  Future<SupplierProfileDisplayModel> getSupplierProfile() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.build4AllAdminProfileMe,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return SupplierProfileDisplayModel.fromJson(data);
      }

      if (data is Map) {
        return SupplierProfileDisplayModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw AppException('Invalid profile response from Build4All');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['message'] != null) return map['message'].toString();
      if (map['error'] != null) return map['error'].toString();
    }

    return e.message ?? 'Unable to load supplier profile';
  }
}
