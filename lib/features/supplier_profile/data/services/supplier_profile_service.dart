import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/picked_file.dart';
import '../../../../core/utils/uploaded_image_url_resolver.dart';
import '../models/supplier_profile_request_model.dart';
import '../models/supplier_profile_response_model.dart';

class SupplierProfileService {
  final ApiClient apiClient;

  SupplierProfileService(this.apiClient);

  Future<String> uploadSupplierLogo(String filePath) async {
    // Already a full URL — a gallery-picked logo, or an R2 link if this ever
    // gets re-submitted unchanged. Neither is a local device file, and
    // there is nothing to upload.
    final trimmed = filePath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return UploadedImageUrlResolver.normalizeForBackend(trimmed);
    }

    try {
      final fileName = pickedFileName(filePath);

      final formData = FormData.fromMap({
        'file': await multipartFromPickedPath(
          filePath,
          filename: fileName,
        ),
      });

      final response = await apiClient.dio.post(
        ApiConfig.supplierProfileLogoUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final logoUrl = data['logoUrl']?.toString();

        if (logoUrl != null && logoUrl.trim().isNotEmpty) {
          return UploadedImageUrlResolver.normalizeForBackend(logoUrl);
        }
      }

      throw AppException('Logo upload response is invalid');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

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
