import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientsUseCase
    implements UseCase<List<Patient>, GetPatientsParams> {
  final PatientRepository repository;

  GetPatientsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Patient>>> call(GetPatientsParams params) {
    return repository.getPatients(page: params.page);
  }
}

class GetPatientsParams {
  final int page;

  const GetPatientsParams({this.page = 1});
}
