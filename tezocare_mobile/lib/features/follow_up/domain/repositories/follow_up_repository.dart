import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_follow_up.dart';

abstract class FollowUpRepository {
  Future<Either<Failure, List<DueFollowUp>>> getDueFollowUps({int? days});
  Future<Either<Failure, Map<String, dynamic>>> markFollowUpDone(String visitId, {required String outcome});
}
