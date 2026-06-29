import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NotificationEvent {
  const GetNotificationsEvent();
}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkAsReadEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class ClearNotificationMessages extends NotificationEvent {
  const ClearNotificationMessages();
}
