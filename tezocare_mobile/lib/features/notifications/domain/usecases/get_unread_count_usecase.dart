import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetUnreadCountUseCase
    implements UseCase<int, NoParams> {
  final NotificationRepository repository;

  GetUnreadCountUseCase({required this.repository});

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.getUnreadCount();
  }
}
