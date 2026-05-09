import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/exceptions.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';
import 'package:tezocare_mobile/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:tezocare_mobile/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:tezocare_mobile/features/dashboard/data/models/refill_model.dart';
import 'package:tezocare_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockRemoteDataSource extends Mock implements DashboardRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late DashboardRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = DashboardRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('getDashboardStats', () {
    const stats = DashboardStatsModel(
      totalPatients: 100,
      activeVisits: 10,
      todayAppointments: 5,
      pendingRefills: 3,
      totalStaff: 8,
      medicationsActive: 20,
    );

    test('should return DashboardStats on success', () async {
      when(() => remoteDataSource.getDashboardStats()).thenAnswer((_) async => stats);

      final result = await repository.getDashboardStats();

      expect(result, const Right(stats));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getDashboardStats();

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => remoteDataSource.getDashboardStats()).thenThrow(
        const ServerException(message: 'Server error', statusCode: 500),
      );

      final result = await repository.getDashboardStats();

      expect(result, Left(ServerFailure(message: 'Server error', statusCode: 500)));
    });
  });

  group('getRefillsDue', () {
    final refills = [
      RefillModel(
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

    test('should return list of Refill on success', () async {
      when(() => remoteDataSource.getRefillsDue()).thenAnswer((_) async => refills);

      final result = await repository.getRefillsDue();

      expect(result.isRight(), true);
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getRefillsDue();

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });
  });
}
