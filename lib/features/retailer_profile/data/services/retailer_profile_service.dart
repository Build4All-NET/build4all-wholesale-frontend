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

  /// Reads account identity from Build4All users table.
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

  /// Updates only account fields Build4All allows directly:
  /// username, firstName, lastName.
  Future<Build4AllUserProfileModel> updateBuild4AllUserProfile({
    required int userId,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'isPublicProfile': 'true',
      });

      final response = await centralApiClient.dio.put(
        ApiConfig.build4AllUserProfile(userId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Build4AllUserProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// Reads business profile from Wholesale backend.
  Future<RetailerBusinessProfileModel> getRetailerBusinessProfile() async {
    try {
      final response = await projectApiClient.dio.get(ApiConfig.retailerProfileMe);

      return RetailerBusinessProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// Updates business data stored in Wholesale DB.
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

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    return e.message ?? 'Something went wrong';
  }
}