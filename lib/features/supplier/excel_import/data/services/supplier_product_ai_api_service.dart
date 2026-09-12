import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/utils/picked_file.dart';
import '../../domain/entities/photographed_supplier_product_entity.dart';

/// Photographing a catalogue into existence, and having the assistant write
/// what the supplier has not: whether the model that makes both of those
/// possible is even configured, storing and naming a batch of photographs,
/// and drafting a description for rows that are not products yet.
class SupplierProductAiApiService {
  final ApiClient apiClient;

  SupplierProductAiApiService(this.apiClient);

  /// Whether photographing products is offered at all. Asked before the
  /// option is shown, rather than showing it and then explaining.
  Future<bool> photosAvailable() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierProductPhotos);
      final data = response.data;
      return data is Map && data['available'] == true;
    } on DioException {
      return false;
    }
  }

  Future<bool> descriptionsAvailable() async {
    try {
      final response =
          await apiClient.dio.get(ApiConfig.supplierProductDescriptions);
      final data = response.data;
      return data is Map && data['available'] == true;
    } on DioException {
      return false;
    }
  }

  /// Stores the photographs in the supplier's gallery and says what each one
  /// appears to be.
  Future<List<PhotographedSupplierProductEntity>> readPhotos(
    List<String> paths,
  ) async {
    try {
      final formData = FormData();

      for (final path in paths) {
        formData.files.add(
          MapEntry(
            'photos',
            await multipartFromPickedPath(path, filename: pickedFileName(path)),
          ),
        );
      }

      final response = await apiClient.dio.post(
        ApiConfig.supplierProductPhotos,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is! List) return const [];

      return data
          .map((item) => _photoFromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  PhotographedSupplierProductEntity _photoFromJson(Map<String, dynamic> json) {
    return PhotographedSupplierProductEntity(
      photoIndex: (json['photoIndex'] as num?)?.toInt() ?? 0,
      galleryImageId: (json['galleryImageId'] as num?)?.toInt(),
      imageUrl: json['imageUrl']?.toString(),
      // What the assistant read, already in the field: correcting a word
      // beats typing a name from nothing.
      name: json['name']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      price: '',
      // The catalogue's own floor. A supplier who wants a smaller minimum
      // still learns that here, but starting blank would have every batch
      // fail the same check one row at a time.
      minimumOrderQuantity: '5',
      description: '',
    );
  }

  /// Creates the products the supplier reviewed and priced. All or nothing:
  /// one row that still fails a rule (a repeated name, say) fails the whole
  /// batch rather than silently dropping it.
  Future<void> createProducts(List<Map<String, Object?>> products) async {
    try {
      await apiClient.dio.post(
        ApiConfig.supplierProductPhotosCreate,
        data: products,
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// Descriptions for rows that are not products yet, keyed by their
  /// position in the photo batch. Nothing is saved: the supplier keeps or
  /// changes the text before the product is created.
  Future<Map<int, String>> draftDescriptions(
    List<Map<String, Object?>> rows,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierProductDescriptionsDraft,
        data: rows,
        options: Options(contentType: 'application/json'),
      );

      final data = response.data;
      if (data is! Map) return const {};

      final byRow = <int, String>{};
      data.forEach((row, text) {
        final number = int.tryParse(row.toString());
        final description = text?.toString().trim() ?? '';
        if (number != null && description.isNotEmpty) byRow[number] = description;
      });

      return byRow;
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
