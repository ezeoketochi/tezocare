import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  Future<Either<Failure, Patient>> createPatient(Patient patient);
  Future<Either<Failure, List<Patient>>> getPatients({int page = 1, String? search, String? status, CancelToken? cancelToken});
  Future<Either<Failure, Patient>> getPatientDetail(String id, {CancelToken? cancelToken});
  Future<Either<Failure, List<Patient>>> searchPatients(String query, {CancelToken? cancelToken});
  Future<Either<Failure, Patient>> updatePatient(Patient patient);

  List<Patient>? getCachedPatients({int page = 1, String? search, String? status});
  Patient? getCachedPatientDetail(String id);
  void cachePatients({int page = 1, String? search, String? status, required List<Patient> patients});
  void cachePatientDetail(String id, Patient patient);
}
