import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/vitals.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_datasource.dart';
import '../models/visit_model.dart';
import '../models/vitals_model.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Visit>> createVisit({
    required Visit visit,
    Vitals? vitals,
  }) async {
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
        visitDate: visit.visitDate,
        reason: visit.reason,
        diagnosis: visit.diagnosis,
        treatment: visit.treatment,
        notes: visit.notes,
        status: visit.status,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
      );
      final vitalsModel = vitals != null
          ? VitalsModel(
              id: vitals.id,
              visitId: vitals.visitId,
              temperature: vitals.temperature,
              heartRate: vitals.heartRate,
              respiratoryRate: vitals.respiratoryRate,
              weight: vitals.weight,
              mucousMembranes: vitals.mucousMembranes,
              capillaryRefillTime: vitals.capillaryRefillTime,
              hydrationStatus: vitals.hydrationStatus,
              otherFindings: vitals.otherFindings,
              recordedAt: vitals.recordedAt,
            )
          : null;
      final result = await remoteDataSource.createVisit(
        visit: visitModel,
        vitals: vitalsModel,
      );
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<Visit>>> getPatientVisits(int patientId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getPatientVisits(patientId);
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitDetail(int id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getVisitDetail(id);
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
