import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/staff.dart';
import 'package:tezocare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository: repository);
  });

  const staff = Staff(
    id: '1',
    name: 'Dr. Smith',
    email: 'smith@tezocare.com',
    isActive: true,
  );

  test('should call repository.getCurrentUser', () async {
    when(() => repository.getCurrentUser())
        .thenAnswer((_) async => const Right(staff));

    final result = await useCase(const NoParams());

    expect(result, const Right(staff));
    verify(() => repository.getCurrentUser()).called(1);
  });

  test('should return UnauthorizedFailure when not authenticated', () async {
    when(() => repository.getCurrentUser()).thenAnswer(
      (_) async => Left(UnauthorizedFailure(message: 'Not authenticated')),
    );

    final result = await useCase(const NoParams());

    expect(result, Left(UnauthorizedFailure(message: 'Not authenticated')));
  });
}
