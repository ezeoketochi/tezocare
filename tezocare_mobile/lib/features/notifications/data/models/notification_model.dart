import '../../domain/entities/notification.dart';

class NotificationModel extends StaffNotification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.status,
    super.patientId,
    super.patientName,
    required super.createdAt,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: _parseType(json['type'] as String? ?? 'other'),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? 'sent'),
      patientId: json['patient_id'] as String?,
      patientName: json['patient_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'status': status.name,
      if (patientId != null) 'patient_id': patientId,
      if (patientName != null) 'patient_name': patientName,
      'created_at': createdAt.toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
    };
  }

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'refill':
        return NotificationType.refill;
      case 'followup':
        return NotificationType.followup;
      case 'test':
        return NotificationType.test;
      default:
        return NotificationType.other;
    }
  }

  static NotificationStatus _parseStatus(String value) {
    switch (value) {
      case 'sent':
        return NotificationStatus.sent;
      case 'pending':
        return NotificationStatus.pending;
      case 'failed':
        return NotificationStatus.failed;
      case 'read':
        return NotificationStatus.read;
      default:
        return NotificationStatus.sent;
    }
  }
}
