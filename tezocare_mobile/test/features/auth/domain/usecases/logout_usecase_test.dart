import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository: repository);
  });

  test('should call repository.logout', () async {
    when(() => repository.logout())
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(const NoParams());

    expect(result, const Right(null));
    verify(() => repository.logout()).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.logout()).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Logout failed')),
    );

    final result = await useCase(const NoParams());

    expect(result, Left(ServerFailure(message: 'Logout failed')));
  });
}
