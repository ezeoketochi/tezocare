import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/due_refill.dart';

abstract class RefillRepository {
  Future<Either<Failure, List<DueRefill>>> getDueRefills({int days = 7});
}
