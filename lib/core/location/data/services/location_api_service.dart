import 'package:dio/dio.dart';

import '../../../exceptions/app_exception.dart';
import '../../../network/api_client.dart';
import '../../../network/api_config.dart';
import '../../blocked_countries.dart';
import '../models/country_model.dart';
import '../models/region_model.dart';

class LocationApiService {
  final ApiClient apiClient;

  LocationApiService(this.apiClient);

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.countries);
      final data = response.data;

      if (data is! List) return [];

      final countries = data
          .map(
            (item) => CountryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((country) => country.active && country.id > 0)
          .where(
            (country) => !BlockedCountries.isBlocked(
              iso2: country.iso2Code,
              iso3: country.iso3Code,
              name: country.name,
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return countries;
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<RegionModel>> getRegionsByCountry(int countryId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.regionsByCountry(countryId.toString()),
      );
      final data = response.data;

      if (data is! List) return [];

      final regions = data
          .map(
            (item) => RegionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((region) => region.active && region.id > 0)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return regions;
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
