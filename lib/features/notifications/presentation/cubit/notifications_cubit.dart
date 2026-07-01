import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final AuthService authService;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markNotificationReadUseCase,
    required this.authService,
  }) : super(NotificationsState.initial());

  // Resolved recipient identity (cached after the first successful resolve).
  int? _projectId;
  int? _recipientId;
  String? _recipientType;

  Future<bool> _ensureIdentity() async {
    if (_projectId != null && _recipientId != null && _recipientType != null) {
      return true;
    }

    final projectId = int.tryParse(AppConfig.ownerProjectLinkId);
    if (projectId == null) {
      return false;
    }

    final me = await authService.getWholesaleMe();
    if (me.userId == 0) {
      return false;
    }

    _projectId = projectId;
    _recipientId = me.userId;
    _recipientType = me.isSupplier ? 'OWNER' : 'CUSTOMER';
    return true;
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final ok = await _ensureIdentity();
      if (!ok) {
        emit(state.copyWith(isLoading: false, notifications: [], unreadCount: 0));
        return;
      }

      final notifications = await getNotificationsUseCase(
        projectId: _projectId!,
        recipientType: _recipientType!,
        recipientId: _recipientId!,
      );

      // Prefer the authoritative server count; fall back to counting the
      // fetched page if that call fails.
      int unread;
      try {
        unread = await getUnreadCountUseCase(
          projectId: _projectId!,
          recipientType: _recipientType!,
          recipientId: _recipientId!,
        );
      } catch (_) {
        unread = notifications.where((n) => !n.read).length;
      }

      emit(
        state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unread,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> markRead(int notificationId) async {
    final alreadyRead = state.notifications
        .any((n) => n.id == notificationId && n.read);
    final exists = state.notifications.any((n) => n.id == notificationId);

    // Nothing to do if it is missing or already read.
    if (!exists || alreadyRead) {
      return;
    }

    // Optimistic update so the UI responds immediately.
    final updated = state.notifications
        .map((n) => n.id == notificationId ? n.copyWith(read: true) : n)
        .toList();
    final unread = state.unreadCount > 0 ? state.unreadCount - 1 : 0;
    emit(state.copyWith(notifications: updated, unreadCount: unread));

    try {
      await markNotificationReadUseCase(notificationId);
    } catch (_) {
      // Revert on failure.
      final reverted = state.notifications
          .map((n) => n.id == notificationId ? n.copyWith(read: false) : n)
          .toList();
      emit(
        state.copyWith(
          notifications: reverted,
          unreadCount: state.unreadCount + 1,
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}
