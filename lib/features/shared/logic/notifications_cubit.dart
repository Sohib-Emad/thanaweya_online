import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/data/repos/notifications_repo.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _repo;
  String? _userId;

  NotificationsCubit({required NotificationsRepo repo})
      : _repo = repo,
        super(const NotificationsState());

  @override
  void emit(NotificationsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadNotifications(String userId) async {
    _userId = userId;
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _repo.getNotifications(userId);
    result.when(
      success: (notifications) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    final result = await _repo.getNotifications(userId);
    result.when(
      success: (notifications) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        errorMessage: message,
      )),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    emit(state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id != notificationId) return n;
        return n.copyWith(isRead: true);
      }).toList(),
    ));
    final result = await _repo.markAsRead(notificationId);
    result.when(success: (_) {}, failure: (_, _) {});
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
    ));
    final result = await _repo.markAllAsRead(userId);
    result.when(success: (_) {}, failure: (_, _) {});
  }
}

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}
