import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class CreatePatientUseCase implements UseCase<Patient, CreatePatientParams> {
  final PatientRepository repository;

  CreatePatientUseCase({required this.repository});

  @override
  Future<Either<Failure, Patient>> call(CreatePatientParams params) {
    return repository.createPatient(params.patient);
  }
}

class CreatePatientParams {
  final Patient patient;

  const CreatePatientParams({required this.patient});
}
