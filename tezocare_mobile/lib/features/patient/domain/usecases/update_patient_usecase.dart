import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class UpdatePatientUseCase implements UseCase<Patient, UpdatePatientParams> {
  final PatientRepository repository;

  UpdatePatientUseCase({required this.repository});

  @override
  Future<Either<Failure, Patient>> call(UpdatePatientParams params) {
    return repository.updatePatient(params.patient);
  }
}

class UpdatePatientParams {
  final Patient patient;

  const UpdatePatientParams({required this.patient});
}
