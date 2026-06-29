import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

enum NotificationLoadStatus { initial, loading, loaded, error }

enum NotificationActionStatus { idle, loading, success, failure }

class NotificationState extends Equatable {
  final List<StaffNotification> notifications;
  final NotificationLoadStatus status;
  final NotificationActionStatus actionStatus;
  final String? errorMessage;
  final String? successMessage;

  const NotificationState({
    this.notifications = const [],
    this.status = NotificationLoadStatus.initial,
    this.actionStatus = NotificationActionStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  factory NotificationState.initial() => const NotificationState();

  List<StaffNotification> get activeNotifications =>
      notifications.where((n) => n.readAt == null).toList();

  List<StaffNotification> get historyNotifications =>
      notifications.where((n) => n.readAt != null).toList();

  int get unreadCount => activeNotifications.length;

  NotificationState copyWith({
    List<StaffNotification>? notifications,
    NotificationLoadStatus? status,
    NotificationActionStatus? actionStatus,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    status,
    actionStatus,
    errorMessage,
    successMessage,
  ];
}
