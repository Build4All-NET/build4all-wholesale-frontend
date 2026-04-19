import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/admin_login_request_model.dart';
import '../models/admin_login_response_model.dart';
import '../models/api_response_model.dart';
import '../models/auth_response_model.dart';
import '../models/build4all_supplier_sync_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/login_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/retailer_signup_request_model.dart';

class AuthService {
  final ApiClient centralApiClient;
  final ApiClient projectApiClient;

  AuthService({
    required this.centralApiClient,
    required this.projectApiClient,
  });

  void _logRequest({
    required String label,
    required Dio dio,
    required String path,
    Object? body,
  }) {
    debugPrint('================ AUTH REQUEST ================');
    debugPrint('$label BASE URL: ${dio.options.baseUrl}');
    debugPrint('$label PATH: $path');
    debugPrint('$label FULL URL: ${dio.options.baseUrl}$path');
    debugPrint('$label BODY: $body');
    debugPrint('=============================================');
  }

  Future<AdminLoginResponseModel> adminLoginFront(
    AdminLoginRequestModel request,
  ) async {
    try {
      _logRequest(
        label: 'ADMIN_LOGIN_FRONT',
        dio: centralApiClient.dio,
        path: ApiConfig.adminLoginFront,
        body: request.toJson(),
      );

      final response = await centralApiClient.dio.post(
        ApiConfig.adminLoginFront,
        data: request.toJson(),
      );

      return AdminLoginResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Admin login failed: $e');
    }
  }

  Future<Map<String, dynamic>> build4AllUserLogin({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'email': email.trim(),
        'password': password,
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
      };

      _logRequest(
        label: 'BUILD4ALL_USER_LOGIN',
        dio: centralApiClient.dio,
        path: ApiConfig.userLogin,
        body: body,
      );

      final response = await centralApiClient.dio.post(
        ApiConfig.userLogin,
        data: body,
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Build4All user login failed: $e');
    }
  }

    Future<void> sendBuild4AllVerification({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'email': email.trim(),
        'password': password,
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
      };

      _logRequest(
        label: 'SEND_BUILD4ALL_VERIFICATION',
        dio: centralApiClient.dio,
        path: ApiConfig.sendVerification,
        body: body,
      );

      await centralApiClient.dio.post(
        ApiConfig.sendVerification,
        data: body,
      );
    } on DioException catch (e) {
      debugPrint('SEND_VERIFICATION STATUS: ${e.response?.statusCode}');
      debugPrint('SEND_VERIFICATION DATA: ${e.response?.data}');
      debugPrint('SEND_VERIFICATION MESSAGE: ${e.message}');
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Failed to send verification code: $e');
    }
  }

  Future<int> verifyBuild4AllEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final body = {
        'email': email.trim(),
        'code': code.trim(),
      };

      _logRequest(
        label: 'VERIFY_BUILD4ALL_EMAIL_CODE',
        dio: centralApiClient.dio,
        path: ApiConfig.verifyEmailCode,
        body: body,
      );

      final response = await centralApiClient.dio.post(
        ApiConfig.verifyEmailCode,
        data: body,
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final user = Map<String, dynamic>.from(data['user'] as Map);
      final id = user['id'];

      if (id is int) return id;
      return int.parse(id.toString());
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Failed to verify code: $e');
    }
  }

  Future<Map<String, dynamic>> completeBuild4AllProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
  }) async {
    try {
      final body = {
        'pendingId': pendingId,
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'isPublicProfile': isPublicProfile.toString(),
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
      };

      _logRequest(
        label: 'COMPLETE_BUILD4ALL_PROFILE',
        dio: centralApiClient.dio,
        path: ApiConfig.completeProfile,
        body: body,
      );

      final formData = FormData.fromMap(body);

      final response = await centralApiClient.dio.post(
        ApiConfig.completeProfile,
        data: formData,
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Failed to complete profile: $e');
    }
  }

  Future<ApiResponseModel> syncSupplierFromBuild4All(
    Build4AllSupplierSyncRequestModel request,
  ) async {
    try {
      _logRequest(
        label: 'SYNC_SUPPLIER_FROM_BUILD4ALL',
        dio: projectApiClient.dio,
        path: ApiConfig.supplierSync,
        body: request.toJson(),
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.supplierSync,
        data: request.toJson(),
      );

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Supplier sync failed: $e');
    }
  }

  Future<ApiResponseModel> syncRetailerFromBuild4All({
    required int build4allUserId,
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String password,
    String? storeName,
    String? storeAddress,
    String? city,
    String? businessType,
  }) async {
    try {
      final body = {
        'build4allUserId': build4allUserId,
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber,
        'password': password,
        'storeName': storeName,
        'storeAddress': storeAddress,
        'city': city,
        'businessType': businessType,
      };

      _logRequest(
        label: 'SYNC_RETAILER_FROM_BUILD4ALL',
        dio: projectApiClient.dio,
        path: ApiConfig.retailerSync,
        body: body,
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.retailerSync,
        data: body,
      );

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Retailer sync failed: $e');
    }
  }

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      _logRequest(
        label: 'WHOLESALE_LOCAL_LOGIN',
        dio: projectApiClient.dio,
        path: ApiConfig.login,
        body: request.toJson(),
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );

      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Login failed: $e');
    }
  }

  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      _logRequest(
        label: 'FORGOT_PASSWORD',
        dio: projectApiClient.dio,
        path: ApiConfig.forgotPassword,
        body: request.toJson(),
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.forgotPassword,
        data: request.toJson(),
      );

      return ForgotPasswordResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Forgot password request failed: $e');
    }
  }

  Future<ApiResponseModel> retailerSignup(
    RetailerSignupRequestModel request,
  ) async {
    try {
      _logRequest(
        label: 'RETAILER_SIGNUP_LOCAL',
        dio: projectApiClient.dio,
        path: ApiConfig.retailerSignup,
        body: request.toJson(),
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.retailerSignup,
        data: request.toJson(),
      );

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Retailer signup failed: $e');
    }
  }

  Future<AuthResponseModel> getCurrentUser() async {
    try {
      _logRequest(
        label: 'GET_CURRENT_USER',
        dio: projectApiClient.dio,
        path: ApiConfig.currentUser,
      );

      final response = await projectApiClient.dio.get(ApiConfig.currentUser);

      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Failed to fetch current user: $e');
    }
  }

  Future<ApiResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      _logRequest(
        label: 'RESET_PASSWORD',
        dio: projectApiClient.dio,
        path: ApiConfig.resetPassword,
        body: request.toJson(),
      );

      final response = await projectApiClient.dio.post(
        ApiConfig.resetPassword,
        data: request.toJson(),
      );

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (e) {
      throw AppException('Reset password request failed: $e');
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    final status = e.response?.statusCode;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final message = map['message']?.toString().trim();
      final error = map['error']?.toString().trim();
      final code = map['code']?.toString().trim();

      final details = map['details'];
      String? requestId;

      if (details is Map) {
        requestId = details['requestId']?.toString();
      }

      if (message != null && message.isNotEmpty) return message;
      if (error != null && error.isNotEmpty) return error;

      if (code != null && code.isNotEmpty) {
        if (requestId != null && requestId.isNotEmpty) {
          return '$code (requestId: $requestId)';
        }
        return code;
      }
    }

    if (status == 400) {
      return 'Bad request. Please check your input.';
    }

    if (status == 401) {
      return 'Invalid email or password.';
    }

    if (status == 403) {
      return 'You are not allowed to access this resource.';
    }

    if (status == 404) {
      return 'Requested endpoint not found.';
    }

    if (status == 409) {
      return 'This email or account already exists.';
    }

    if (status != null && status >= 500) {
      return 'Server error from Build4All. Check backend logs.';
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

    return e.message ?? 'Something went wrong.';
  }
}