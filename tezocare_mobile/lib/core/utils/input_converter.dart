import 'package:dartz/dartz.dart';
import '../error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) {
        return Left(ValidationFailure(message: 'Value must be non-negative'));
      }
      return Right(integer);
    } on FormatException {
      return Left(ValidationFailure(message: 'Invalid number format'));
    }
  }

  Either<Failure, double> stringToDouble(String str) {
    try {
      final value = double.parse(str);
      return Right(value);
    } on FormatException {
      return Left(ValidationFailure(message: 'Invalid number format'));
    }
  }
}
