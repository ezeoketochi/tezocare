import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';
import '../entities/vitals.dart';

abstract class VisitRepository {
  Future<Either<Failure, Visit>> createVisit({
    required Visit visit,
    Vitals? vitals,
  });
  Future<Either<Failure, List<Visit>>> getPatientVisits(int patientId);
  Future<Either<Failure, Visit>> getVisitDetail(int id);
}
