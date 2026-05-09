import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tezocare_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tezocare_mobile/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  late GetDashboardStatsUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetDashboardStatsUseCase(repository: repository);
  });

  const stats = DashboardStats(
    totalPatients: 100,
    activeVisits: 10,
    todayAppointments: 5,
    pendingRefills: 3,
    totalStaff: 8,
    medicationsActive: 20,
  );

  test('should call repository.getDashboardStats', () async {
    when(() => repository.getDashboardStats())
        .thenAnswer((_) async => const Right(stats));

    final result = await useCase(const NoParams());

    expect(result, const Right(stats));
    verify(() => repository.getDashboardStats()).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.getDashboardStats()).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error')),
    );

    final result = await useCase(const NoParams());

    expect(result, Left(ServerFailure(message: 'Server error')));
  });
}
