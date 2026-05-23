import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_follow_up.dart';

abstract class FollowUpRepository {
  Future<Either<Failure, List<DueFollowUp>>> getDueFollowUps({int days = 7});
  Future<Either<Failure, void>> markFollowUpDone(String visitId, {required String outcome});
}
