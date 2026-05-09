import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../entities/vitals.dart';
import '../repositories/visit_repository.dart';

class CreateVisitUseCase implements UseCase<Visit, CreateVisitParams> {
  final VisitRepository repository;

  CreateVisitUseCase({required this.repository});

  @override
  Future<Either<Failure, Visit>> call(CreateVisitParams params) {
    return repository.createVisit(
      visit: params.visit,
      vitals: params.vitals,
    );
  }
}

class CreateVisitParams {
  final Visit visit;
  final Vitals? vitals;

  const CreateVisitParams({required this.visit, this.vitals});
}
