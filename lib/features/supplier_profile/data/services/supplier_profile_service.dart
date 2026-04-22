import 'package:dio/dio.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/supplier_profile_request_model.dart';
import '../models/supplier_profile_response_model.dart';

class SupplierProfileService {
  final ApiClient apiClient;

  SupplierProfileService(this.apiClient);

  Future<SupplierProfileResponseModel> createSupplierProfile({
    required SupplierProfileRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierProfile,
        data: request.toJson(),
      );

      return SupplierProfileResponseModel.fromJson(response.data);
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
