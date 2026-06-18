import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_follow_up.dart';

abstract class FollowUpRepository {
  Future<Either<Failure, List<DueFollowUp>>> getDueFollowUps({String? filter, int? days, CancelToken? cancelToken});
  Future<Either<Failure, Map<String, dynamic>>> markFollowUpDone(String visitId, {required String outcome});
  Future<List<DueFollowUp>> getLocalDueFollowUps();
  Future<void> saveLocalDueFollowUps(List<DueFollowUp> followUps);
}
