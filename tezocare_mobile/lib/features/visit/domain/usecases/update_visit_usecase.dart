import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class UpdateVisitUseCase implements UseCase<Visit, UpdateVisitParams> {
  final VisitRepository repository;

  UpdateVisitUseCase({required this.repository});

  @override
  Future<Either<Failure, Visit>> call(UpdateVisitParams params) {
    return repository.updateVisit(params.id, params.visit);
  }
}

class UpdateVisitParams {
  final String id;
  final Visit visit;

  const UpdateVisitParams({required this.id, required this.visit});
}
