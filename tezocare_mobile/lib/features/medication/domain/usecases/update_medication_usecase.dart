import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class UpdateMedicationUseCase
    implements UseCase<Medication, UpdateMedicationParams> {
  final MedicationRepository repository;

  UpdateMedicationUseCase({required this.repository});

  @override
  Future<Either<Failure, Medication>> call(UpdateMedicationParams params) {
    return repository.updateMedication(params.medication);
  }
}

class UpdateMedicationParams {
  final Medication medication;

  const UpdateMedicationParams({required this.medication});
}
