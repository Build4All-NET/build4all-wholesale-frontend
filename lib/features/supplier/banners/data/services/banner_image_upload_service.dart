import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';

class BannerImageUploadService {
  final ApiClient apiClient;

  BannerImageUploadService(this.apiClient);

  Future<String> uploadBannerImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last.split('\\').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await apiClient.dio.post(
        ApiConfig.supplierBannerUploadImage,
        data: formData,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final imageUrl = data['imageUrl']?.toString();

        if (imageUrl != null && imageUrl.trim().isNotEmpty) {
          return imageUrl.trim();
        }
      }

      throw AppException('Image upload response is invalid');
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

    return e.message ?? 'Failed to upload image';
  }
}