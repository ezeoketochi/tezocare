import 'package:equatable/equatable.dart';

enum NotificationType { refill, followup, test, other }

enum NotificationStatus { sent, pending, failed, read }

class StaffNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationStatus status;
  final String? patientId;
  final String? patientName;
  final DateTime createdAt;
  final DateTime? readAt;

  const StaffNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.status = NotificationStatus.sent,
    this.patientId,
    this.patientName,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  StaffNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    NotificationStatus? status,
    String? patientId,
    String? patientName,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return StaffNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    message,
    status,
    patientId,
    patientName,
    createdAt,
    readAt,
  ];
}
