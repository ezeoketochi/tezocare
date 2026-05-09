import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/refill.dart';
import '../repositories/dashboard_repository.dart';

class GetRefillsDueUseCase implements UseCase<List<Refill>, NoParams> {
  final DashboardRepository repository;

  GetRefillsDueUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Refill>>> call(NoParams params) {
    return repository.getRefillsDue();
  }
}
