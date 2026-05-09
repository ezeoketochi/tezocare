import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase implements UseCase<Token, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCase({required this.repository});

  @override
  Future<Either<Failure, Token>> call(RefreshTokenParams params) {
    return repository.refreshToken(params.refreshToken);
  }
}

class RefreshTokenParams {
  final String refreshToken;

  const RefreshTokenParams({required this.refreshToken});
}
