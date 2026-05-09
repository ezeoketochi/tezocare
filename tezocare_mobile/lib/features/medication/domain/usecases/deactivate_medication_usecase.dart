import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class DeactivateMedicationUseCase
    implements UseCase<void, DeactivateMedicationParams> {
  final MedicationRepository repository;

  DeactivateMedicationUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeactivateMedicationParams params) {
    return repository.deactivateMedication(params.id);
  }
}

class DeactivateMedicationParams {
  final int id;

  const DeactivateMedicationParams({required this.id});
}
