import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<StaffNotification>, NoParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<StaffNotification>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
