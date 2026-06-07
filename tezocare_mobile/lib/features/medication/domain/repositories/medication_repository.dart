import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<Either<Failure, Medication>> addMedication(Medication medication);
  Future<Either<Failure, List<Medication>>> getPatientMedications(
    String patientId, {
    CancelToken? cancelToken,
  });
  Future<Either<Failure, Medication>> updateMedication(Medication medication);
  Future<Either<Failure, void>> deactivateMedication(String id);

  Future<List<Medication>?> getLocalPatientMedications(String patientId);
  Future<void> saveLocalPatientMedications(String patientId, List<Medication> medications);
}
