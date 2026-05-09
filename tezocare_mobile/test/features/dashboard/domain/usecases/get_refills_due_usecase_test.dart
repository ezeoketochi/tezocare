import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/refill.dart';
import 'package:tezocare_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tezocare_mobile/features/dashboard/domain/usecases/get_refills_due_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  late GetRefillsDueUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetRefillsDueUseCase(repository: repository);
  });

  final refills = [
    Refill(
      id: 1,
      medicationId: 1,
      medicationName: 'Amoxicillin',
      patientId: 1,
      patientName: 'Buddy',
      lastRefillDate: DateTime(2025, 3, 1),
      nextRefillDate: DateTime(2025, 3, 28),
      isOverdue: false,
    ),
  ];

  test('should call repository.getRefillsDue', () async {
    when(() => repository.getRefillsDue())
        .thenAnswer((_) async => Right(refills));

    final result = await useCase(const NoParams());

    expect(result, Right(refills));
    verify(() => repository.getRefillsDue()).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.getRefillsDue()).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error')),
    );

    final result = await useCase(const NoParams());

    expect(result, Left(ServerFailure(message: 'Server error')));
  });
}
