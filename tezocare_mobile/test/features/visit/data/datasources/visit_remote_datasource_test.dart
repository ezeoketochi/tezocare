import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/dio_client.dart';
import 'package:tezocare_mobile/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:tezocare_mobile/features/visit/data/models/visit_model.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late VisitRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    dataSource = VisitRemoteDataSourceImpl(dioClient: dioClient);
    when(() => dioClient.dio).thenReturn(dio);
  });

  group('createVisit', () {
    test('should return created VisitModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'patient_id': 1,
          'staff_id': 1,
          'visit_date': '2025-03-10T14:00:00.000',
          'status': 'completed',
        },
      });
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => response);

      final visit = VisitModel(id: 0, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'scheduled');
      final result = await dataSource.createVisit(visit: visit, vitals: null);

      expect(result.id, 1);
      expect(result.status, 'completed');
    });
  });

  group('getPatientVisits', () {
    test('should return list of VisitModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [
          {
            'id': 1,
            'patient_id': 1,
            'staff_id': 1,
            'visit_date': '2025-03-10T14:00:00.000',
            'status': 'completed',
          },
        ],
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getPatientVisits(1);

      expect(result.length, 1);
      expect(result[0].id, 1);
    });
  });

  group('getVisitDetail', () {
    test('should return VisitModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'patient_id': 1,
          'staff_id': 1,
          'visit_date': '2025-03-10T14:00:00.000',
          'status': 'completed',
        },
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getVisitDetail(1);

      expect(result.id, 1);
    });
  });
}
