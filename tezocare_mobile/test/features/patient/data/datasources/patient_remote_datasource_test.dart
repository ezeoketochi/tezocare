import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/dio_client.dart';
import 'package:tezocare_mobile/features/patient/data/datasources/patient_remote_datasource.dart';
import 'package:tezocare_mobile/features/patient/data/models/patient_model.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late PatientRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    dataSource = PatientRemoteDataSourceImpl(dioClient: dioClient);
    when(() => dioClient.dio).thenReturn(dio);
  });

  group('getPatients', () {
    test('should return list of PatientModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [
          {
            'id': 1,
            'name': 'Buddy',
            'species': 'Canine',
            'is_active': true,
          },
        ],
      });
      when(() => dio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer((_) async => response);

      final result = await dataSource.getPatients(page: 1);

      expect(result.length, 1);
      expect(result[0].name, 'Buddy');
    });
  });

  group('getPatientDetail', () {
    test('should return PatientModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'name': 'Buddy',
          'species': 'Canine',
          'is_active': true,
        },
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getPatientDetail(1);

      expect(result.id, 1);
      expect(result.name, 'Buddy');
    });
  });

  group('searchPatients', () {
    test('should return list of PatientModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [
          {
            'id': 1,
            'name': 'Buddy',
            'species': 'Canine',
            'is_active': true,
          },
        ],
      });
      when(() => dio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer((_) async => response);

      final result = await dataSource.searchPatients('Buddy');

      expect(result.length, 1);
      expect(result[0].name, 'Buddy');
    });
  });

  group('createPatient', () {
    test('should return created PatientModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'name': 'Buddy',
          'species': 'Canine',
          'is_active': true,
        },
      });
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => response);

      final patient = PatientModel(id: 0, name: 'Buddy', species: 'Canine', isActive: true);
      final result = await dataSource.createPatient(patient);

      expect(result.id, 1);
      expect(result.name, 'Buddy');
    });
  });

  group('updatePatient', () {
    test('should return updated PatientModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'name': 'Buddy Updated',
          'species': 'Canine',
          'is_active': true,
        },
      });
      when(() => dio.put(any(), data: any(named: 'data'))).thenAnswer((_) async => response);

      final patient = PatientModel(id: 1, name: 'Buddy Updated', species: 'Canine', isActive: true);
      final result = await dataSource.updatePatient(patient);

      expect(result.name, 'Buddy Updated');
    });
  });
}
