import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_datasource.dart';
import '../models/visit_model.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
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
  Future<Either<Failure, List<Visit>>> getPatientVisits(String patientId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientVisits(patientId);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getVisitDetail(id);
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
  Future<Either<Failure, Visit>> referVisit(String id, {required String destination, required String reason}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.referVisit(id, destination: destination, reason: reason);
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
}
