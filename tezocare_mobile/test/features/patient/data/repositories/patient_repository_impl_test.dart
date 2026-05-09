import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/exceptions.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';
import 'package:tezocare_mobile/features/patient/data/datasources/patient_remote_datasource.dart';
import 'package:tezocare_mobile/features/patient/data/models/patient_model.dart';
import 'package:tezocare_mobile/features/patient/data/repositories/patient_repository_impl.dart';

class MockRemoteDataSource extends Mock implements PatientRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late PatientRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const PatientModel(id: 0, name: '', species: '', isActive: false));
  });

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = PatientRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('getPatients', () {
    test('should return list of Patient on success', () async {
      when(() => remoteDataSource.getPatients(page: any(named: 'page'))).thenAnswer(
        (_) async => [],
      );

      final result = await repository.getPatients(page: 1);

      expect(result.isRight(), true);
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getPatients(page: 1);

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });
  });

  group('createPatient', () {
    const patient = PatientModel(id: 0, name: 'Buddy', species: 'Canine', isActive: true);

    test('should return created Patient on success', () async {
      when(() => remoteDataSource.createPatient(any())).thenAnswer((_) async => patient);

      final result = await repository.createPatient(patient);

      expect(result, const Right(patient));
    });

    test('should return ValidationFailure on ValidationException', () async {
      when(() => remoteDataSource.createPatient(any())).thenThrow(
        const ValidationException(message: 'Name required'),
      );

      final result = await repository.createPatient(patient);

      expect(result, Left(ValidationFailure(message: 'Name required')));
    });
  });
}
