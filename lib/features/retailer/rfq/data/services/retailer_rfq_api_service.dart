import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/repositories/retailer_rfq_repository.dart';
import '../models/rfq_quotation_model.dart';
import '../models/rfq_request_model.dart';

class RetailerRfqApiService {
  final ApiClient apiClient;

  RetailerRfqApiService(this.apiClient);

  Future<List<RfqRequestModel>> getMyRfqs() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.retailerRfqs);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) =>
                  RfqRequestModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RfqRequestModel> getRfqDetails(int rfqId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerRfqById(rfqId),
      );

      return RfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RfqRequestModel> createRfq(CreateRfqParams params) async {
    try {
      final imageUrl = await _resolveImageUrl(
        imagePath: params.imagePath,
        existingUrl: params.imageUrl,
      );

      final response = await apiClient.dio.post(
        ApiConfig.retailerRfqs,
        data: _buildCreateBody(params, imageUrl),
      );

      return RfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RfqRequestModel> updateRfq({
    required int rfqId,
    required UpdateRfqParams params,
  }) async {
    try {
      final imageUrl = await _resolveImageUrl(
        imagePath: params.imagePath,
        existingUrl: params.imageUrl,
      );

      final response = await apiClient.dio.put(
        ApiConfig.retailerRfqById(rfqId),
        data: _buildUpdateBody(params, imageUrl),
      );

      return RfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RfqRequestModel> cancelRfq(int rfqId) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.cancelRetailerRfq(rfqId),
      );

      return RfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteRfq(int rfqId) async {
    try {
      await apiClient.dio.delete(ApiConfig.retailerRfqById(rfqId));
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<RfqQuotationModel>> getRfqQuotations(int rfqId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerRfqQuotations(rfqId),
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) =>
                  RfqQuotationModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RfqRequestModel> acceptQuotation({
    required int rfqId,
    required int quotationId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.acceptRetailerRfqQuotation(rfqId, quotationId),
      );

      return RfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Map<String, dynamic> _buildCreateBody(
    CreateRfqParams params,
    String? imageUrl,
  ) {
    return {
      'productName': params.productName.trim(),
      'requirements': params.requirements.trim(),
      'imageUrl': imageUrl,
      'categoryId': params.categoryId,
      'categoryName': _emptyToNull(params.categoryName),
      'subCategoryId': params.subCategoryId,
      'subCategoryName': _emptyToNull(params.subCategoryName),
      'productId': params.productId,
      'quantity': params.quantity,
      'unit': params.unit.trim().isEmpty ? 'units' : params.unit.trim(),
      'targetUnitPrice': params.targetUnitPrice,
      'preferredDeliveryLabel': params.preferredDeliveryLabel.trim().isEmpty
          ? 'Within 1 week'
          : params.preferredDeliveryLabel.trim(),
      'preferredDeliveryDays': params.preferredDeliveryDays,
      'deadlineDate': _dateToJson(params.deadlineDate),
      'deliveryCountryId': params.deliveryCountryId,
      'deliveryCountryName': _emptyToNull(params.deliveryCountryName),
      'deliveryCountryIso2Code': _emptyToNull(params.deliveryCountryIso2Code),
      'deliveryCountryIso3Code': _emptyToNull(params.deliveryCountryIso3Code),
      'deliveryRegionId': params.deliveryRegionId,
      'deliveryRegionName': _emptyToNull(params.deliveryRegionName),
      'deliveryRegionCode': _emptyToNull(params.deliveryRegionCode),
      'deliveryCity': _emptyToNull(params.deliveryCity),
      'deliveryAddress': _emptyToNull(params.deliveryAddress),
      'aiGenerated': params.aiGenerated,
    };
  }

  Map<String, dynamic> _buildUpdateBody(
    UpdateRfqParams params,
    String? imageUrl,
  ) {
    return {
      'productName': params.productName.trim(),
      'requirements': params.requirements.trim(),
      'imageUrl': imageUrl,
      'categoryId': params.categoryId,
      'categoryName': _emptyToNull(params.categoryName),
      'subCategoryId': params.subCategoryId,
      'subCategoryName': _emptyToNull(params.subCategoryName),
      'productId': params.productId,
      'quantity': params.quantity,
      'unit': params.unit.trim().isEmpty ? 'units' : params.unit.trim(),
      'targetUnitPrice': params.targetUnitPrice,
      'preferredDeliveryLabel': params.preferredDeliveryLabel.trim().isEmpty
          ? 'Within 1 week'
          : params.preferredDeliveryLabel.trim(),
      'preferredDeliveryDays': params.preferredDeliveryDays,
      'deadlineDate': _dateToJson(params.deadlineDate),
      'deliveryCountryId': params.deliveryCountryId,
      'deliveryCountryName': _emptyToNull(params.deliveryCountryName),
      'deliveryCountryIso2Code': _emptyToNull(params.deliveryCountryIso2Code),
      'deliveryCountryIso3Code': _emptyToNull(params.deliveryCountryIso3Code),
      'deliveryRegionId': params.deliveryRegionId,
      'deliveryRegionName': _emptyToNull(params.deliveryRegionName),
      'deliveryRegionCode': _emptyToNull(params.deliveryRegionCode),
      'deliveryCity': _emptyToNull(params.deliveryCity),
      'deliveryAddress': _emptyToNull(params.deliveryAddress),
      'aiGenerated': params.aiGenerated,
    };
  }

  Future<String?> _resolveImageUrl({
    required String? imagePath,
    required String? existingUrl,
  }) async {
    final existing = _emptyToNull(existingUrl);
    if (existing != null) return _normalizeUploadUrl(existing);

    final path = _emptyToNull(imagePath);
    if (path == null) return null;

    if (path.startsWith('/uploadsPublic/') ||
        path.contains('/uploadsPublic/')) {
      return _normalizeUploadUrl(path);
    }

    final file = File(path);

    if (!file.existsSync()) return null;

    return _uploadRfqImage(file);
  }

  Future<String> _uploadRfqImage(File file) async {
    try {
      final fileName = file.path.split(RegExp(r'[\\/]')).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await apiClient.dio.post(
        ApiConfig.retailerRfqImageUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;

      if (data is Map && data['imageUrl'] != null) {
        return data['imageUrl'].toString();
      }

      throw AppException('RFQ image upload failed');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) return null;

    return trimmed;
  }

  String _normalizeUploadUrl(String value) {
    if (value.startsWith('/uploadsPublic/')) return value;

    if (value.contains('/uploadsPublic/')) {
      return value.substring(value.indexOf('/uploadsPublic/'));
    }

    return value;
  }

  String? _dateToJson(DateTime? date) {
    if (date == null) return null;

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    return e.message ?? 'RFQ request failed';
  }
}
