import 'package:dio/dio.dart';

import '../../exceptions/app_exception.dart';
import '../../network/api_client.dart';
import '../../network/api_config.dart';
import 'app_currency_model.dart';

class AppCurrencyApiService {
  final ApiClient apiClient;

  AppCurrencyApiService(this.apiClient);

  Future<AppCurrencyModel> getCurrencyById(int id) async {
    try {
      final response = await apiClient.dio.get(ApiConfig.currencyById(id));
      final data = response.data;

      if (data is Map) {
        return AppCurrencyModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw AppException('Invalid currency response');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return e.message ?? 'Unable to load currency';
  }
}
