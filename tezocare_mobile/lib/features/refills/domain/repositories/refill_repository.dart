import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_refill.dart';

abstract class RefillRepository {
  Future<Either<Failure, List<DueRefill>>> getDueRefills({String? filter, int? days});
  Future<Either<Failure, void>> markContacted(String refillId);
  Future<Either<Failure, void>> markRefilled(String refillId);
  Future<Either<Failure, List<String>>> createRefillsBatch(List<Map<String, dynamic>> medications);
}
