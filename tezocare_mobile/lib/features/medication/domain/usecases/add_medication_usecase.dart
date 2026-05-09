import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class AddMedicationUseCase implements UseCase<Medication, AddMedicationParams> {
  final MedicationRepository repository;

  AddMedicationUseCase({required this.repository});

  @override
  Future<Either<Failure, Medication>> call(AddMedicationParams params) {
    return repository.addMedication(params.medication);
  }
}

class AddMedicationParams {
  final Medication medication;

  const AddMedicationParams({required this.medication});
}
