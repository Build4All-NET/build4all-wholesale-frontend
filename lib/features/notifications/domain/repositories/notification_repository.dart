import '../entities/notification_entity.dart';

/// Reads and updates the current user's in-app notifications.
///
/// The recipient identity (`projectId`, `recipientType`, `recipientId`) is
/// resolved by the caller and passed through, since the shared notify endpoints
/// are generic and do not infer the actor from the token.
abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    required int projectId,
    required String recipientType,
    required int recipientId,
    int page,
    int size,
  });

  Future<int> getUnreadCount({
    required int projectId,
    required String recipientType,
    required int recipientId,
  });

  Future<void> markRead(int notificationId);
}
