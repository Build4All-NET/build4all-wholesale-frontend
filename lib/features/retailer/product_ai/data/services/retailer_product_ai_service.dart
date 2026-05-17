import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/retailer_product_ai_chat_response_model.dart';

class RetailerProductAiService {
  final ApiClient projectApiClient;

  RetailerProductAiService({required this.projectApiClient});

  Future<RetailerProductAiChatResponseModel> chatAboutProduct({
    required int productId,
    required String message,
  }) async {
    try {
      final response = await projectApiClient.dio.post(
        ApiConfig.retailerProductAiChat(productId),
        data: {'message': message.trim()},
      );

      return RetailerProductAiChatResponseModel.fromJson(
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

    return e.message ?? 'AI assistant is temporarily unavailable';
  }
}
