import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PatientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Patient>> createPatient(Patient patient) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final patientModel = PatientModel(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth ?? DateTime(2000, 1, 1),
        gender: patient.gender,
        phone: patient.phone,
        address: patient.address,
        state: patient.state,
        city: patient.city,
        occupation: patient.occupation,
        bloodGroup: patient.bloodGroup,
        genotype: patient.genotype,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        isActive: patient.isActive,
      );
      final result = await remoteDataSource.createPatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> getPatients({int page = 1, String? search, String? status}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatients(page: page, search: search, status: status);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Patient>> getPatientDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientDetail(id);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> searchPatients(String query) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.searchPatients(query);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Patient>> updatePatient(Patient patient) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final patientModel = PatientModel(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth ?? DateTime(2000, 1, 1),
        gender: patient.gender,
        phone: patient.phone,
        address: patient.address,
        state: patient.state,
        city: patient.city,
        occupation: patient.occupation,
        bloodGroup: patient.bloodGroup,
        genotype: patient.genotype,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        isActive: patient.isActive,
      );
      final result = await remoteDataSource.updatePatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }
}
