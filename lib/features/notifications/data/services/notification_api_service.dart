import 'package:dio/dio.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/notification_model.dart';

/// Talks to the shared notify library endpoints exposed by the wholesale
/// backend under `/api/notify`. Uses the project API client (wholesale backend).
class NotificationApiService {
  final ApiClient apiClient;

  NotificationApiService(this.apiClient);

  Future<List<NotificationModel>> getNotifications({
    required int projectId,
    required String recipientType,
    required int recipientId,
    int page = 0,
    int size = 30,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.notifyNotifications,
        queryParameters: {
          'projectId': projectId,
          'recipientType': recipientType,
          'recipientId': recipientId,
          'page': page,
          'size': size,
        },
      );

      final data = response.data;

      // The endpoint returns a Spring Page: { content: [...], ... }.
      final content = data is Map ? data['content'] : data;

      if (content is List) {
        return content
            .map(
              (item) => NotificationModel.fromJson(
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

  Future<int> getUnreadCount({
    required int projectId,
    required String recipientType,
    required int recipientId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.notifyUnreadCount,
        queryParameters: {
          'projectId': projectId,
          'recipientType': recipientType,
          'recipientId': recipientId,
        },
      );

      final data = response.data;
      if (data is Map && data['unread'] != null) {
        final unread = data['unread'];
        if (unread is num) return unread.toInt();
        return int.tryParse(unread.toString()) ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> markRead(int notificationId) async {
    try {
      await apiClient.dio.post(ApiConfig.notifyMarkRead(notificationId));
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
