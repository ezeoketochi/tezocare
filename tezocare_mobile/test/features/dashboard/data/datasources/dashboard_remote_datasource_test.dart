import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/dio_client.dart';
import 'package:tezocare_mobile/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late DashboardRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    dataSource = DashboardRemoteDataSourceImpl(dioClient: dioClient);
    when(() => dioClient.dio).thenReturn(dio);
  });

  group('getDashboardStats', () {
    test('should return DashboardStatsModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'total_patients': 150,
          'active_visits': 12,
          'today_appointments': 8,
          'pending_refills': 5,
          'total_staff': 10,
          'medications_active': 45,
        },
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getDashboardStats();

      expect(result.totalPatients, 150);
      expect(result.activeVisits, 12);
      expect(result.todayAppointments, 8);
    });
  });

  group('getRefillsDue', () {
    test('should return list of RefillModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [
          {
            'id': 1,
            'medication_id': 1,
            'medication_name': 'Amoxicillin',
            'patient_id': 1,
            'patient_name': 'Buddy',
            'last_refill_date': '2025-03-01T00:00:00.000',
            'next_refill_date': '2025-03-28T00:00:00.000',
            'is_overdue': false,
          },
        ],
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getRefillsDue();

      expect(result.length, 1);
      expect(result[0].medicationName, 'Amoxicillin');
    });
  });
}
