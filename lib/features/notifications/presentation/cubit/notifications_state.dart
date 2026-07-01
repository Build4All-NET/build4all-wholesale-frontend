import '../../domain/entities/notification_entity.dart';

class NotificationsState {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? errorMessage;

  const NotificationsState({
    required this.isLoading,
    required this.notifications,
    required this.unreadCount,
    required this.errorMessage,
  });

  factory NotificationsState.initial() {
    return const NotificationsState(
      isLoading: false,
      notifications: [],
      unreadCount: 0,
      errorMessage: null,
    );
  }

  bool get isEmpty => notifications.isEmpty;

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
