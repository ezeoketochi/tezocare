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
        name: patient.name,
        species: patient.species,
        breed: patient.breed,
        color: patient.color,
        gender: patient.gender,
        dateOfBirth: patient.dateOfBirth,
        weight: patient.weight,
        microchipId: patient.microchipId,
        ownerId: patient.ownerId,
        ownerName: patient.ownerName,
        ownerPhone: patient.ownerPhone,
        ownerEmail: patient.ownerEmail,
        notes: patient.notes,
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
  Future<Either<Failure, Patient>> getPatientDetail(int id) async {
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
        name: patient.name,
        species: patient.species,
        breed: patient.breed,
        color: patient.color,
        gender: patient.gender,
        dateOfBirth: patient.dateOfBirth,
        weight: patient.weight,
        microchipId: patient.microchipId,
        ownerId: patient.ownerId,
        ownerName: patient.ownerName,
        ownerPhone: patient.ownerPhone,
        ownerEmail: patient.ownerEmail,
        notes: patient.notes,
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
