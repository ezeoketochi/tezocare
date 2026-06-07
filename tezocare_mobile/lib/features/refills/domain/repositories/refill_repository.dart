import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_refill.dart';

abstract class RefillRepository {
  Future<Either<Failure, List<DueRefill>>> getDueRefills({String? filter, int? days, CancelToken? cancelToken});
  Future<Either<Failure, void>> markContacted(String refillId);
  Future<Either<Failure, void>> markRefilled(String refillId);
  Future<Either<Failure, List<String>>> createRefillsBatch(List<Map<String, dynamic>> medications);
  Future<List<DueRefill>> getLocalDueRefills();
  Future<void> saveLocalDueRefills(List<DueRefill> refills);
}
