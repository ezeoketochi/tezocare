import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetPatientMedicationsUseCase
    implements UseCase<List<Medication>, GetPatientMedicationsParams> {
  final MedicationRepository repository;

  GetPatientMedicationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Medication>>> call(
    GetPatientMedicationsParams params,
  ) {
    return repository.getPatientMedications(params.patientId);
  }
}

class GetPatientMedicationsParams {
  final String patientId;

  const GetPatientMedicationsParams({required this.patientId});
}
