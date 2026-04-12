import 'package:dio/dio.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/api_response_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/retailer_signup_request_model.dart';
import '../models/reset_password_request_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<AuthResponseModel> login(LoginRequestModel request) async {
  try {
    debugPrint('LOGIN URL: ${ApiConfig.baseUrl}${ApiConfig.login}');
    debugPrint('LOGIN BODY: ${request.toJson()}');

    final response = await apiClient.dio.post(
      ApiConfig.login,
      data: request.toJson(),
    );

    debugPrint('LOGIN RESPONSE: ${response.data}');
    return AuthResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    debugPrint('LOGIN ERROR TYPE: ${e.type}');
    debugPrint('LOGIN ERROR MESSAGE: ${e.message}');
    debugPrint('LOGIN ERROR RESPONSE: ${e.response?.data}');
    throw AppException(_extractMessage(e));
  } catch (e) {
    debugPrint('LOGIN UNKNOWN ERROR: $e');
    throw AppException('Login failed');
  }
}
  Future<ForgotPasswordResponseModel> forgotPassword(
  ForgotPasswordRequestModel request,
) async {
  try {
    final response = await apiClient.dio.post(
      ApiConfig.forgotPassword,
      data: request.toJson(),
    );

    return ForgotPasswordResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    throw AppException(_extractMessage(e));
  } catch (_) {
    throw AppException('Forgot password request failed');
  }
}


  Future<ApiResponseModel> retailerSignup(
  RetailerSignupRequestModel request,
) async {
  try {
    debugPrint('SIGNUP URL: ${ApiConfig.baseUrl}${ApiConfig.retailerSignup}');
    debugPrint('SIGNUP BODY: ${request.toJson()}');

    final response = await apiClient.dio.post(
      ApiConfig.retailerSignup,
      data: request.toJson(),
    );

    debugPrint('SIGNUP RESPONSE: ${response.data}');
    return ApiResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    debugPrint('SIGNUP ERROR TYPE: ${e.type}');
    debugPrint('SIGNUP ERROR MESSAGE: ${e.message}');
    debugPrint('SIGNUP ERROR RESPONSE: ${e.response?.data}');
    throw AppException(_extractMessage(e));
  } catch (e) {
    debugPrint('SIGNUP UNKNOWN ERROR: $e');
    throw AppException('Retailer signup failed');
  }
}

  Future<AuthResponseModel> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.currentUser);

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Failed to fetch current user');
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

  if (e.type == DioExceptionType.connectionTimeout) {
    return 'Connection timeout. Check if backend is running.';
  }

  if (e.type == DioExceptionType.receiveTimeout) {
    return 'Server took too long to respond.';
  }

  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot connect to backend.';
  }

  return e.message ?? 'Something went wrong';
}
  Future<ApiResponseModel> resetPassword(
  ResetPasswordRequestModel request,
) async {
  try {
    final response = await apiClient.dio.post(
      ApiConfig.resetPassword,
      data: request.toJson(),
    );

    return ApiResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    throw AppException(_extractMessage(e));
  } catch (_) {
    throw AppException('Reset password request failed');
  }
}

}
