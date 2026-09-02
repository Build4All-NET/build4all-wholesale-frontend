import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/utils/picked_file.dart';
import '../../domain/entities/gallery_image_entity.dart';

class SupplierGalleryApiService {
  final ApiClient apiClient;

  SupplierGalleryApiService(this.apiClient);

  Future<List<GalleryImageEntity>> listImages() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierGallery);

      final data = response.data;
      if (data is List) {
        return data
            .map(
              (item) => GalleryImageEntity.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<GalleryImageEntity> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await multipartFromPickedPath(
          filePath,
          filename: pickedFileName(filePath),
        ),
      });

      final response = await apiClient.dio.post(
        ApiConfig.supplierGallery,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return GalleryImageEntity.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      await apiClient.dio.delete(ApiConfig.supplierGalleryById(imageId));
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
