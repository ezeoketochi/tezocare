import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/exceptions.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';
import 'package:tezocare_mobile/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:tezocare_mobile/features/visit/data/models/visit_model.dart';
import 'package:tezocare_mobile/features/visit/data/models/vitals_model.dart';
import 'package:tezocare_mobile/features/visit/data/repositories/visit_repository_impl.dart';

class MockRemoteDataSource extends Mock implements VisitRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late VisitRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(VisitModel(id: 0, patientId: 0, staffId: 0, visitDate: DateTime(2025, 1, 1), status: ''));
    registerFallbackValue(const VitalsModel());
  });

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = VisitRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('createVisit', () {
    final visit = VisitModel(id: 1, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'completed');

    test('should return Visit on success', () async {
      when(() => remoteDataSource.createVisit(visit: any(named: 'visit'), vitals: any(named: 'vitals'))).thenAnswer(
        (_) async => visit,
      );

      final result = await repository.createVisit(visit: visit, vitals: null);

      expect(result, Right(visit));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.createVisit(visit: visit, vitals: null);

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => remoteDataSource.createVisit(visit: any(named: 'visit'), vitals: any(named: 'vitals'))).thenThrow(
        const ServerException(message: 'Server error', statusCode: 500),
      );

      final result = await repository.createVisit(visit: visit, vitals: null);

      expect(result, Left(ServerFailure(message: 'Server error', statusCode: 500)));
    });
  });

  group('getPatientVisits', () {
    test('should return list of Visit on success', () async {
      when(() => remoteDataSource.getPatientVisits(any())).thenAnswer(
        (_) async => [],
      );

      final result = await repository.getPatientVisits(1);

      expect(result.isRight(), true);
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getPatientVisits(1);

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });
  });

  group('getVisitDetail', () {
    final visit = VisitModel(id: 1, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'completed');

    test('should return Visit on success', () async {
      when(() => remoteDataSource.getVisitDetail(any())).thenAnswer((_) async => visit);

      final result = await repository.getVisitDetail(1);

      expect(result, Right(visit));
    });

    test('should return NotFoundFailure on NotFoundException', () async {
      when(() => remoteDataSource.getVisitDetail(any())).thenThrow(
        const NotFoundException(message: 'Visit not found'),
      );

      final result = await repository.getVisitDetail(999);

      expect(result, Left(NotFoundFailure(message: 'Visit not found')));
    });
  });
}
