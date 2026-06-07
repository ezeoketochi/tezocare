import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
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
        duration: medication.duration,
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
    String patientId, {
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientMedications(
        patientId,
        cancelToken: cancelToken,
      );
      saveLocalPatientMedications(patientId, result);
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
        duration: medication.duration,
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
  Future<Either<Failure, void>> deactivateMedication(String id) async {
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

  @override
  Future<List<Medication>?> getLocalPatientMedications(String patientId) async {
    return cacheService.getAs<List<Medication>>('medications_$patientId');
  }

  @override
  Future<void> saveLocalPatientMedications(String patientId, List<Medication> medications) async {
    cacheService.put('medications_$patientId', medications);
  }
}
