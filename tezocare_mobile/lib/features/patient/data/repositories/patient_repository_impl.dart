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
        fullName: patient.fullName,
        dob: patient.dob,
        gender: patient.gender,
        bloodGroup: patient.bloodGroup,
        phone: patient.phone,
        address: patient.address,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        isActive: patient.isActive,
        createdAt: patient.createdAt,
        updatedAt: patient.updatedAt,
      );
      final result = await remoteDataSource.createPatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> getPatients({int page = 1}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatients(page: page);
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
        fullName: patient.fullName,
        dob: patient.dob,
        gender: patient.gender,
        bloodGroup: patient.bloodGroup,
        phone: patient.phone,
        address: patient.address,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        isActive: patient.isActive,
        createdAt: patient.createdAt,
        updatedAt: patient.updatedAt,
      );
      final result = await remoteDataSource.updatePatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }
}
