import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetPatientVisitsUseCase
    implements UseCase<List<Visit>, GetPatientVisitsParams> {
  final VisitRepository repository;

  GetPatientVisitsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Visit>>> call(GetPatientVisitsParams params) {
    return repository.getPatientVisits(params.patientId);
  }
}

class GetPatientVisitsParams {
  final String patientId;

  const GetPatientVisitsParams({required this.patientId});
}
