import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/dio_client.dart';
import 'package:tezocare_mobile/features/medication/data/datasources/medication_remote_datasource.dart';
import 'package:tezocare_mobile/features/medication/data/models/medication_model.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late MedicationRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    dataSource = MedicationRemoteDataSourceImpl(dioClient: dioClient);
    when(() => dioClient.dio).thenReturn(dio);
  });

  group('addMedication', () {
    test('should return created MedicationModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'patient_id': 1,
          'name': 'Amoxicillin',
          'is_active': true,
        },
      });
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => response);

      final medication = MedicationModel(id: 0, patientId: 1, name: 'Amoxicillin', isActive: true);
      final result = await dataSource.addMedication(medication);

      expect(result.id, 1);
      expect(result.name, 'Amoxicillin');
    });
  });

  group('getPatientMedications', () {
    test('should return list of MedicationModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [
          {
            'id': 1,
            'patient_id': 1,
            'name': 'Amoxicillin',
            'is_active': true,
          },
        ],
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getPatientMedications(1);

      expect(result.length, 1);
      expect(result[0].name, 'Amoxicillin');
    });
  });

  group('deactivateMedication', () {
    test('should call delete on success', () async {
      when(() => dio.delete(any())).thenAnswer((_) async => MockResponse());

      await dataSource.deactivateMedication(1);

      verify(() => dio.delete(any())).called(1);
    });
  });
}
