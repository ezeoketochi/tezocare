import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<Either<Failure, Medication>> addMedication(Medication medication);
  Future<Either<Failure, List<Medication>>> getPatientMedications(
    String patientId,
  );
  Future<Either<Failure, Medication>> updateMedication(Medication medication);
  Future<Either<Failure, void>> deactivateMedication(String id);
}
