import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/refill.dart';
import 'package:tezocare_mobile/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:tezocare_mobile/features/dashboard/domain/usecases/get_refills_due_usecase.dart';
import 'package:tezocare_mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:tezocare_mobile/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:tezocare_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetDashboardStatsUseCase extends Mock implements GetDashboardStatsUseCase {}
class MockGetRefillsDueUseCase extends Mock implements GetRefillsDueUseCase {}

void main() {
  late MockGetDashboardStatsUseCase getDashboardStatsUseCase;
  late MockGetRefillsDueUseCase getRefillsDueUseCase;

  setUp(() {
    getDashboardStatsUseCase = MockGetDashboardStatsUseCase();
    getRefillsDueUseCase = MockGetRefillsDueUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  const stats = DashboardStats(
    totalPatients: 100,
    activeVisits: 10,
    todayAppointments: 5,
    pendingRefills: 3,
    totalStaff: 8,
    medicationsActive: 20,
  );

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Loaded] when getDashboardStats succeeds',
      build: () {
        when(() => getDashboardStatsUseCase(any())).thenAnswer(
          (_) async => const Right(stats),
        );
        when(() => getRefillsDueUseCase(any())).thenAnswer(
          (_) async => const Right(<Refill>[]),
        );
        return DashboardBloc(
          getDashboardStatsUseCase: getDashboardStatsUseCase,
          getRefillsDueUseCase: getRefillsDueUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetDashboardStatsEvent()),
      expect: () => [
        const DashboardLoading(),
        const DashboardLoaded(stats: stats, refillsDue: <Refill>[]),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when getDashboardStats fails',
      build: () {
        when(() => getDashboardStatsUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );
        when(() => getRefillsDueUseCase(any())).thenAnswer(
          (_) async => const Right(<Refill>[]),
        );
        return DashboardBloc(
          getDashboardStatsUseCase: getDashboardStatsUseCase,
          getRefillsDueUseCase: getRefillsDueUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetDashboardStatsEvent()),
      expect: () => [
        const DashboardLoading(),
        const DashboardError(message: 'Server error'),
      ],
    );
  });
}
