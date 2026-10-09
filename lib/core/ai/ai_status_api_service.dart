import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_config.dart';

/// Asks the server whether this store's plan includes AI.
class AiStatusApiService {
  /// Key of the flag in the server's answer.
  static const String enabledKey = 'aiEnabled';

  final ApiClient apiClient;

  AiStatusApiService(this.apiClient);

  /// Whether AI is on for this store.
  ///
  /// Fails closed: an answer that cannot be read, or no answer at all, counts
  /// as "off". A store that has AI loses a button until the next successful
  /// check; a store that does not would otherwise be shown options the server
  /// refuses.
  Future<bool> fetchAiEnabled() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.aiStatus);
      final data = response.data;
      return data is Map && data[enabledKey] == true;
    } on DioException {
      return false;
    }
  }
}
