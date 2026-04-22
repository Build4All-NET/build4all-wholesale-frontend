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

class AuthService {
  final ApiClient centralApiClient;
  final ApiClient projectApiClient;

  AuthService({required this.centralApiClient, required this.projectApiClient});

  Future<AdminLoginResponseModel> adminLoginFront(
    AdminLoginRequestModel request,
  ) async {
    try {
      final response = await centralApiClient.dio.post(
        ApiConfig.adminLoginFront,
        data: request.toJson(),
      );
      return AdminLoginResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> build4AllUserLogin({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'usernameOrEmail': email.trim(),
        'password': password,
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
      };

      final response = await centralApiClient.dio.post(
        ApiConfig.userLogin,
        data: body,
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
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
          'email': email.trim(),
          'password': password.trim(),
          'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
        },
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<int> verifyBuild4AllEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await centralApiClient.dio.post(
        ApiConfig.verifyEmailCode,
        data: {'email': email.trim(), 'code': code.trim()},
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final user = Map<String, dynamic>.from(data['user'] as Map);
      final id = user['id'];

      if (id is int) return id;
      return int.parse(id.toString());
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> completeBuild4AllProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    String? profileImagePath,
  }) async {
    try {
      final map = <String, dynamic>{
        'pendingId': pendingId,
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'isPublicProfile': isPublicProfile.toString(),
        'ownerProjectLinkId': int.tryParse(AppConfig.ownerProjectLinkId),
      };

      if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
        map['profileImage'] = await MultipartFile.fromFile(profileImagePath);
      }

      final response = await centralApiClient.dio.post(
        ApiConfig.completeProfile,
        data: FormData.fromMap(map),
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<ApiResponseModel> syncRetailerFromBuild4All({
    required int build4allUserId,
    required int ownerProjectLinkId,
    required String username,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final response = await projectApiClient.dio.post(
        ApiConfig.retailerSync,
        data: {
          'build4allUserId': build4allUserId,
          'ownerProjectLinkId': ownerProjectLinkId,
          'username': username.trim(),
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
        },
      );

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
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

      return ApiResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<AuthResponseModel> getWholesaleMe() async {
    try {
      final response = await projectApiClient.dio.get(ApiConfig.currentUser);
      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> updateRetailerProfile({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  }) async {
    try {
      await projectApiClient.dio.put(
        ApiConfig.retailerProfileMe,
        data: {
          'fullName': fullName,
          'storeName': storeName,
          'phoneNumber': phoneNumber,
          'storeAddress': storeAddress,
          'city': city,
          'businessType': businessType,
        },
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
