import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/repositories/supplier_rfq_repository.dart';
import '../models/supplier_rfq_request_model.dart';

class SupplierRfqApiService {
  final ApiClient apiClient;

  SupplierRfqApiService(this.apiClient);

  Future<List<SupplierRfqRequestModel>> getOpenRfqs() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierRfqsOpen);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => SupplierRfqRequestModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierRfqRequestModel> getRfqDetails(int rfqId) async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierRfqById(rfqId));
      return SupplierRfqRequestModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> submitQuotation({
    required int rfqId,
    required SupplierQuotationParams params,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConfig.submitSupplierRfqQuotation(rfqId),
        data: _buildQuotationBody(params),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> updateQuotation({
    required int quotationId,
    required SupplierQuotationParams params,
  }) async {
    try {
      await apiClient.dio.put(
        ApiConfig.updateSupplierRfqQuotation(quotationId),
        data: _buildQuotationBody(params),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> withdrawQuotation(int quotationId) async {
    try {
      await apiClient.dio.post(
        ApiConfig.withdrawSupplierRfqQuotation(quotationId),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Map<String, dynamic> _buildQuotationBody(SupplierQuotationParams params) {
    return {
      'unitPrice': params.unitPrice,
      'availableQuantity': params.availableQuantity,
      'deliveryDate': _dateToJson(params.deliveryDate),
      'shippingCost': params.shippingCost,
      'message': _emptyToNull(params.message),
    };
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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

    return e.message ?? 'Supplier RFQ request failed';
  }
}
