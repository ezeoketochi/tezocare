import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  Future<Either<Failure, Patient>> createPatient(Patient patient);
  Future<Either<Failure, List<Patient>>> getPatients({int page = 1, String? search, String? status});
  Future<Either<Failure, Patient>> getPatientDetail(String id);
  Future<Either<Failure, List<Patient>>> searchPatients(String query);
  Future<Either<Failure, Patient>> updatePatient(Patient patient);
}
