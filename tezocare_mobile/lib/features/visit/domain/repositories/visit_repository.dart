import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';

abstract class VisitRepository {
  Future<Either<Failure, Visit>> createVisit(Visit visit);
  Future<Either<Failure, Visit>> updateVisit(String id, Visit visit);
  Future<Either<Failure, List<Visit>>> getPatientVisits(
    String patientId, {
    CancelToken? cancelToken,
  });
  Future<Either<Failure, Visit>> getVisitDetail(
    String id, {
    CancelToken? cancelToken,
  });
  Future<Either<Failure, Visit>> completeVisit(String id);
  Future<Either<Failure, Visit>> referVisit(
    String id, {
    required String destination,
    required String reason,
  });
  Future<Either<Failure, Visit>> markFollowUpDone(String id);
  Future<Either<Failure, void>> deleteVisit(String id);

  Future<List<Visit>> getLocalVisits(String patientId);
  Future<void> saveLocalVisits(String patientId, List<Visit> visits);
  Future<Visit?> getLocalVisitDetail(String id);
  Future<void> saveLocalVisitDetail(Visit visit);
}
