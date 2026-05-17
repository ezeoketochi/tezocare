import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Medication>> addMedication(
    Medication medication,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final medicationModel = MedicationModel(
        id: medication.id,
        patientId: medication.patientId,
        patientName: medication.patientName,
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        route: medication.route,
        startDate: medication.startDate,
        endDate: medication.endDate,
        prescribedBy: medication.prescribedBy,
        notes: medication.notes,
        isActive: medication.isActive,
        createdAt: medication.createdAt,
        updatedAt: medication.updatedAt,
      );
      final result = await remoteDataSource.addMedication(medicationModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getPatientMedications(
    String patientId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientMedications(patientId);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Medication>> updateMedication(
    Medication medication,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final medicationModel = MedicationModel(
        id: medication.id,
        patientId: medication.patientId,
        patientName: medication.patientName,
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        route: medication.route,
        startDate: medication.startDate,
        endDate: medication.endDate,
        prescribedBy: medication.prescribedBy,
        notes: medication.notes,
        isActive: medication.isActive,
        createdAt: medication.createdAt,
        updatedAt: medication.updatedAt,
      );
      final result = await remoteDataSource.updateMedication(medicationModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deactivateMedication(int id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deactivateMedication(id);
      return const Right(null);
    } catch (e) {
      return handleException(e);
    }
  }
}
