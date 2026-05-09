import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/token.dart';
import 'package:tezocare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RefreshTokenUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = RefreshTokenUseCase(repository: repository);
  });

  const params = RefreshTokenParams(refreshToken: 'refresh-token');
  const token = Token(
    accessToken: 'new-access',
    refreshToken: 'new-refresh',
  );

  test('should call repository.refreshToken with correct token', () async {
    when(() => repository.refreshToken(any()))
        .thenAnswer((_) async => const Right(token));

    final result = await useCase(params);

    expect(result, const Right(token));
    verify(() => repository.refreshToken('refresh-token')).called(1);
  });

  test('should return UnauthorizedFailure when refresh fails', () async {
    when(() => repository.refreshToken(any())).thenAnswer(
      (_) async => Left(UnauthorizedFailure(message: 'Token expired')),
    );

    final result = await useCase(params);

    expect(result, Left(UnauthorizedFailure(message: 'Token expired')));
  });
}
