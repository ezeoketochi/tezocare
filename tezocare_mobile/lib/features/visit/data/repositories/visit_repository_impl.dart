import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_datasource.dart';
import '../models/visit_model.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, Visit>> createVisit(Visit visit) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final visitModel = VisitModel(
        id: visit.id,
        patientId: visit.patientId,
        patientName: visit.patientName,
        staffId: visit.staffId,
        staffName: visit.staffName,
        visitNumber: visit.visitNumber,
        visitDate: visit.visitDate,
        status: visit.status,
        chiefComplaints: visit.chiefComplaints,
        medicationHistory: visit.medicationHistory,
        vitals: visit.vitals,
        testResults: visit.testResults,
        clinicalAssessment: visit.clinicalAssessment,
        medicationsDispensed: visit.medicationsDispensed,
        counsellingAdvice: visit.counsellingAdvice,
        followUp: visit.followUp,
        referral: visit.referral,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
      );
      final result = await remoteDataSource.createVisit(visitModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> updateVisit(String id, Visit visit) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final visitModel = VisitModel(
        id: visit.id,
        patientId: visit.patientId,
        patientName: visit.patientName,
        staffId: visit.staffId,
        staffName: visit.staffName,
        visitNumber: visit.visitNumber,
        visitDate: visit.visitDate,
        status: visit.status,
        chiefComplaints: visit.chiefComplaints,
        medicationHistory: visit.medicationHistory,
        vitals: visit.vitals,
        testResults: visit.testResults,
        clinicalAssessment: visit.clinicalAssessment,
        medicationsDispensed: visit.medicationsDispensed,
        counsellingAdvice: visit.counsellingAdvice,
        followUp: visit.followUp,
        referral: visit.referral,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
      );
      final result = await remoteDataSource.updateVisit(id, visitModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Visit>>> getPatientVisits(
    String patientId, {
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientVisits(
        patientId,
        cancelToken: cancelToken,
      );
      await saveLocalVisits(patientId, result);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitDetail(
    String id, {
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getVisitDetail(
        id,
        cancelToken: cancelToken,
      );
      await saveLocalVisitDetail(result);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> completeVisit(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.completeVisit(id);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> referVisit(
    String id, {
    required String destination,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.referVisit(
        id,
        destination: destination,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> markFollowUpDone(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.markFollowUpDone(id);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteVisit(id);
      return const Right(null);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<List<Visit>> getLocalVisits(String patientId) async {
    final cached = cacheService.getAs<List<Visit>>('visits_$patientId');
    return cached ?? [];
  }

  @override
  Future<void> saveLocalVisits(String patientId, List<Visit> visits) async {
    cacheService.put('visits_$patientId', visits);
  }

  @override
  Future<void> saveVisitsToLocalCache(
    String patientId,
    List<Visit> visits,
  ) async {
    cacheService.put('visits_$patientId', visits);
  }

  @override
  Future<Visit?> getLocalVisitDetail(String id) async {
    return cacheService.getAs<Visit>('visit_detail_$id');
  }

  @override
  Future<void> saveLocalVisitDetail(Visit visit) async {
    cacheService.put('visit_detail_${visit.id}', visit);
  }

  @override
  Future<void> deleteLocalVisit(String visitId) async {
    cacheService.remove('visit_detail_$visitId');
  }

  @override
  Stream<List<Visit>> watchPatientVisits(String patientId) {
    return cacheService
        .watch<List<Visit>>('visits_$patientId')
        .map((data) => data ?? []);
  }
}
