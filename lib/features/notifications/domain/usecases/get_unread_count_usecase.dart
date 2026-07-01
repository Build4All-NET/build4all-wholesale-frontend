import '../repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<int> call({
    required int projectId,
    required String recipientType,
    required int recipientId,
  }) {
    return repository.getUnreadCount(
      projectId: projectId,
      recipientType: recipientType,
      recipientId: recipientId,
    );
  }
}
