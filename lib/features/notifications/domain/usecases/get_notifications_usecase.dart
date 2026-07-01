import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call({
    required int projectId,
    required String recipientType,
    required int recipientId,
    int page = 0,
    int size = 30,
  }) {
    return repository.getNotifications(
      projectId: projectId,
      recipientType: recipientType,
      recipientId: recipientId,
      page: page,
      size: size,
    );
  }
}
