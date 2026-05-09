import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/token.dart';
import 'package:tezocare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository: repository);
  });

  const params = LoginParams(email: 'test@test.com', password: 'password123');
  const token = Token(
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  test('should call repository.login with correct credentials', () async {
    when(() => repository.login(any(), any()))
        .thenAnswer((_) async => const Right(token));

    final result = await useCase(params);

    expect(result, const Right(token));
    verify(() => repository.login('test@test.com', 'password123')).called(1);
  });

  test('should return UnauthorizedFailure when login fails', () async {
    when(() => repository.login(any(), any())).thenAnswer(
      (_) async => Left(UnauthorizedFailure(message: 'Invalid credentials')),
    );

    final result = await useCase(params);

    expect(result, Left(UnauthorizedFailure(message: 'Invalid credentials')));
  });

  test('should return ValidationFailure on validation error', () async {
    when(() => repository.login(any(), any())).thenAnswer(
      (_) async => Left(ValidationFailure(message: 'Invalid email')),
    );

    final result = await useCase(params);

    expect(result, Left(ValidationFailure(message: 'Invalid email')));
  });

  test('should return ServerFailure on server error', () async {
    when(() => repository.login(any(), any())).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error', statusCode: 500)),
    );

    final result = await useCase(params);

    expect(result, Left(ServerFailure(message: 'Server error', statusCode: 500)));
  });
}
