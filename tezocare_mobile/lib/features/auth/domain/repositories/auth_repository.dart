import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff.dart';
import '../entities/token.dart';

abstract class AuthRepository {
  Future<Either<Failure, Token>> login(String email, String password);
  Future<Either<Failure, Staff>> getCurrentUser();
  Future<Either<Failure, Token>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
}
