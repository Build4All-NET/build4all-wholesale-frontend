import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService apiService;

  NotificationRepositoryImpl(this.apiService);

  @override
  Future<List<NotificationEntity>> getNotifications({
    required int projectId,
    required String recipientType,
    required int recipientId,
    int page = 0,
    int size = 30,
  }) {
    return apiService.getNotifications(
      projectId: projectId,
      recipientType: recipientType,
      recipientId: recipientId,
      page: page,
      size: size,
    );
  }

  @override
  Future<int> getUnreadCount({
    required int projectId,
    required String recipientType,
    required int recipientId,
  }) {
    return apiService.getUnreadCount(
      projectId: projectId,
      recipientType: recipientType,
      recipientId: recipientId,
    );
  }

  @override
  Future<void> markRead(int notificationId) {
    return apiService.markRead(notificationId);
  }
}
