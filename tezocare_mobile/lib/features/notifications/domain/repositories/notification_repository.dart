import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<StaffNotification>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<List<StaffNotification>> getLocalNotifications();
  Future<void> saveLocalNotifications(List<StaffNotification> notifications);
}
