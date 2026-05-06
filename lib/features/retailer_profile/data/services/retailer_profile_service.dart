import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/retailer_profile_model.dart';

class RetailerProfileService {
  final ApiClient centralApiClient;
  final ApiClient projectApiClient;

  RetailerProfileService({
    required this.centralApiClient,
    required this.projectApiClient,
  });

  Future<Build4AllUserProfileModel> getBuild4AllUserProfile(int userId) async {
    try {
      final response = await centralApiClient.dio.get(
        ApiConfig.build4AllUserById(userId),
      );

      return Build4AllUserProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<AccountProfileUpdateResult> updateBuild4AllUserProfile({
    required int userId,
    required String username,
    required String firstName,
    required String lastName,
    String? changedEmail,
  }) async {
    try {
      final data = <String, dynamic>{
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'isPublicProfile': 'true',
      };

      if (changedEmail != null && changedEmail.trim().isNotEmpty) {
        data['email'] = changedEmail.trim();
      }

      final formData = FormData.fromMap(data);

      final response = await centralApiClient.dio.put(
        ApiConfig.build4AllUserProfile(userId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return AccountProfileUpdateResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> verifyEmailChange({
    required int userId,
    required String code,
  }) async {
    try {
      await centralApiClient.dio.post(
        ApiConfig.build4AllVerifyEmailChange(userId),
        data: {'code': code.trim()},
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> resendEmailChangeCode({required int userId}) async {
    try {
      await centralApiClient.dio.post(
        ApiConfig.build4AllResendEmailChange(userId),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> sendPasswordResetCode({
    required String email,
    required int ownerProjectLinkId,
  }) async {
    try {
      await centralApiClient.dio.post(
        ApiConfig.build4AllResetPassword(ownerProjectLinkId),
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> updatePasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
    required int ownerProjectLinkId,
  }) async {
    try {
      await centralApiClient.dio.post(
        ApiConfig.build4AllUpdatePassword(ownerProjectLinkId),
        data: {
          'email': email.trim(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerBusinessProfileModel> getRetailerBusinessProfile() async {
    try {
      final response = await projectApiClient.dio.get(
        ApiConfig.retailerProfileMe,
      );

      return RetailerBusinessProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerBusinessProfileModel> updateRetailerBusinessProfile({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  }) async {
    try {
      final response = await projectApiClient.dio.put(
        ApiConfig.retailerProfileMe,
        data: {
          'fullName': fullName,
          'storeName': storeName.trim(),
          'phoneNumber': phoneNumber.trim(),
          'storeAddress': storeAddress.trim(),
          'city': city.trim(),
          'businessType': businessType.trim(),
        },
      );

      return RetailerBusinessProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteBuild4AllUser({
    required int userId,
    required String password,
  }) async {
    try {
      await centralApiClient.dio.delete(
        ApiConfig.build4AllDeleteUser(userId),
        data: {'password': password},
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteRetailerBusinessProfile() async {
    try {
      await projectApiClient.dio.delete(ApiConfig.retailerProfileMe);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['code'] != null) return data['code'].toString();
    }

    return e.message ?? 'Something went wrong';
  }
}
