import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/tax_preview_model.dart';
import '../models/tax_rule_model.dart';

class TaxRuleApiService {
  final ApiClient apiClient;

  TaxRuleApiService(this.apiClient);

  Future<List<TaxRuleModel>> getTaxRules() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierTaxRules);

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => TaxRuleModel.fromJson(
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

  Future<TaxRuleModel> createTaxRule(TaxRuleModel model) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierTaxRules,
        data: model.toRequestJson(),
      );

      return TaxRuleModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<TaxRuleModel> updateTaxRule(TaxRuleModel model) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierTaxRuleById(model.id),
        data: model.toRequestJson(),
      );

      return TaxRuleModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteTaxRule(String id) async {
    try {
      await apiClient.dio.delete(ApiConfig.supplierTaxRuleById(id));
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<TaxPreviewModel> previewTax({
    required String countryId,
    String? regionId,
    required double itemsSubtotal,
    double promotionDiscount = 0,
    double shippingCost = 0,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierTaxPreview,
        data: {
          'countryId': int.tryParse(countryId),
          'regionId': regionId == null ? null : int.tryParse(regionId),
          'itemsSubtotal': itemsSubtotal,
          'promotionDiscount': promotionDiscount,
          'shippingCost': shippingCost,
        },
      );

      return TaxPreviewModel.fromJson(
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