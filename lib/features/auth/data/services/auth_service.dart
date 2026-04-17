import 'package:dio/dio.dart';

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

  Future<AdminLoginResponseModel> adminLoginFront(
    AdminLoginRequestModel request,
  ) async {
    try {
      final response = await centralApiClient.dio.post(
        ApiConfig.adminLoginFront,
        data: request.toJson(),
      );

      return AdminLoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Admin login failed');
    }
  }

  Future<Map<String, dynamic>> build4AllUserLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await centralApiClient.dio.post(
        ApiConfig.userLogin,
        data: {
          'email': email,
          'password': password,
          'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Build4All user login failed');
    }
  }

  Future<void> sendBuild4AllVerification({
    required String email,
    required String password,
  }) async {
    try {
      await centralApiClient.dio.post(
        ApiConfig.sendVerification,
        data: {
          'email': email,
          'password': password,
          'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
        },
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Failed to send verification code');
    }
  }

  Future<int> verifyBuild4AllEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await centralApiClient.dio.post(
        ApiConfig.verifyEmailCode,
        data: {
          'email': email,
          'code': code,
        },
      );

      final data = Map<String, dynamic>.from(response.data);
      final user = Map<String, dynamic>.from(data['user'] as Map);
      final id = user['id'];
      if (id is int) return id;
      return int.parse(id.toString());
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Failed to verify code');
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
      final formData = FormData.fromMap({
        'pendingId': pendingId,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'isPublicProfile': isPublicProfile.toString(),
        'ownerProjectLinkId': AppConfig.ownerProjectLinkId,
      });

      final response = await centralApiClient.dio.post(
        ApiConfig.completeProfile,
        data: formData,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Failed to complete profile');
    }
  }

  Future<ApiResponseModel> syncSupplierFromBuild4All(
    Build4AllSupplierSyncRequestModel request,
  ) async {
    try {
      final response = await projectApiClient.dio.post(
        ApiConfig.supplierSync,
        data: request.toJson(),
      );

      return ApiResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Supplier sync failed');
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
      final response = await projectApiClient.dio.post(
        ApiConfig.retailerSync,
        data: {
          'build4allUserId': build4allUserId,
          'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'storeName': storeName,
          'storeAddress': storeAddress,
          'city': city,
          'businessType': businessType,
        },
      );

      return ApiResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Retailer sync failed');
    }
  }

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await projectApiClient.dio.post(
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
      final response = await projectApiClient.dio.post(
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
      final response = await projectApiClient.dio.post(
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
      final response = await projectApiClient.dio.get(ApiConfig.currentUser);
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    } catch (_) {
      throw AppException('Failed to fetch current user');
    }
  }

  Future<ApiResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await projectApiClient.dio.post(
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

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['code'] != null && data['message'] != null) {
        return '${data['code']}: ${data['message']}';
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
}