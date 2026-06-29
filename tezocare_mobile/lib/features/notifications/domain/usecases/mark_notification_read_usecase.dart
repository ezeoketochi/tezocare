import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase
    implements UseCase<void, MarkNotificationReadParams> {
  final NotificationRepository repository;

  MarkNotificationReadUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkNotificationReadParams params) {
    return repository.markAsRead(params.notificationId);
  }
}

class MarkNotificationReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationReadParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}
