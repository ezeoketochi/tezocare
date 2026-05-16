import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientDetailUseCase implements UseCase<Patient, GetPatientDetailParams> {
  final PatientRepository repository;

  GetPatientDetailUseCase({required this.repository});

  @override
  Future<Either<Failure, Patient>> call(GetPatientDetailParams params) {
    return repository.getPatientDetail(params.id);
  }
}

class GetPatientDetailParams {
  final String id;

  const GetPatientDetailParams({required this.id});
}
