import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/tax_location_model.dart';

class TaxLocationApiService {
  final ApiClient apiClient;

  TaxLocationApiService(this.apiClient);

  Future<List<TaxCountryModel>> getCountries() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.countries);

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => TaxCountryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((country) => country.id.isNotEmpty && country.active)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<TaxRegionModel>> getRegionsByCountry(String countryId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.regionsByCountry(countryId),
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => TaxRegionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((region) => region.id.isNotEmpty && region.active)
            .toList();
      }

      return [];
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