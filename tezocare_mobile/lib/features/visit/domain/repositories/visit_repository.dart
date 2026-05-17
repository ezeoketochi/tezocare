import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';

abstract class VisitRepository {
  Future<Either<Failure, Visit>> createVisit(Visit visit);
  Future<Either<Failure, List<Visit>>> getPatientVisits(String patientId);
  Future<Either<Failure, Visit>> getVisitDetail(int id);
  Future<Either<Failure, Visit>> completeVisit(int id);
  Future<Either<Failure, Visit>> referVisit(int id, {required String destination, required String reason});
  Future<Either<Failure, Visit>> markFollowUpDone(int id);
}
