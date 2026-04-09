import 'package:dio/dio.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';

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
      final response = await apiClient.dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
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
      final response = await apiClient.dio.post(
        ApiConfig.retailerSignup,
        data: request.toJson(),
      );

      return ApiResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
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
    }

    return 'Something went wrong';
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
