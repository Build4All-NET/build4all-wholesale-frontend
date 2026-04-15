import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/supplier_profile_request_model.dart';
import '../models/supplier_profile_response_model.dart';

class SupplierProfileService {
  final ApiClient apiClient;

  SupplierProfileService(this.apiClient);

  Future<SupplierProfileResponseModel> createSupplierProfile({
    required int userId,
    required SupplierProfileRequestModel request,
  }) async {
    try {
      debugPrint('SUPPLIER PROFILE URL: ${ApiConfig.projectApiBaseUrl}${ApiConfig.supplierProfile}');
      debugPrint('SUPPLIER PROFILE BODY: ${request.toJson()}');

      final response = await apiClient.dio.post(
        ApiConfig.supplierProfile,
        data: request.toJson(),
      );

      debugPrint('SUPPLIER PROFILE RESPONSE: ${response.data}');
      return SupplierProfileResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('SUPPLIER PROFILE ERROR TYPE: ${e.type}');
      debugPrint('SUPPLIER PROFILE ERROR MESSAGE: ${e.message}');
      debugPrint('SUPPLIER PROFILE ERROR RESPONSE: ${e.response?.data}');
      throw AppException(_extractMessage(e));
    } catch (e) {
      debugPrint('SUPPLIER PROFILE UNKNOWN ERROR: $e');
      throw AppException('Failed to complete supplier profile');
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    return e.message ?? 'Something went wrong';
  }
}