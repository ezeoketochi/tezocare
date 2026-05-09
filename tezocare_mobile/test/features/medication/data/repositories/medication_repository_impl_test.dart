import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/exceptions.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';
import 'package:tezocare_mobile/features/medication/data/datasources/medication_remote_datasource.dart';
import 'package:tezocare_mobile/features/medication/data/models/medication_model.dart';
import 'package:tezocare_mobile/features/medication/data/repositories/medication_repository_impl.dart';

class MockRemoteDataSource extends Mock implements MedicationRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late MedicationRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const MedicationModel(id: 0, patientId: 0, name: '', isActive: false));
  });

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = MedicationRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('addMedication', () {
    const medication = MedicationModel(id: 1, patientId: 1, name: 'Amoxicillin', isActive: true);

    test('should return Medication on success', () async {
      when(() => remoteDataSource.addMedication(any())).thenAnswer((_) async => medication);

      final result = await repository.addMedication(medication);

      expect(result, const Right(medication));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.addMedication(medication);

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });

    test('should return ValidationFailure on ValidationException', () async {
      when(() => remoteDataSource.addMedication(any())).thenThrow(
        const ValidationException(message: 'Name required', errors: {'name': 'required'}),
      );

      final result = await repository.addMedication(medication);

      expect(result, Left(ValidationFailure(message: 'Name required', errors: {'name': 'required'})));
    });
  });

  group('getPatientMedications', () {
    test('should return list of Medication on success', () async {
      when(() => remoteDataSource.getPatientMedications(any())).thenAnswer(
        (_) async => [],
      );

      final result = await repository.getPatientMedications(1);

      expect(result.isRight(), true);
    });
  });
}
