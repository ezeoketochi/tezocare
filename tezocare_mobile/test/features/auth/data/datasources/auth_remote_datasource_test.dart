import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/network/dio_client.dart';
import 'package:tezocare_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late MockSecureStorage secureStorage;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    secureStorage = MockSecureStorage();
    dataSource = AuthRemoteDataSourceImpl(
      dioClient: dioClient,
      secureStorage: secureStorage,
    );
    when(() => dioClient.dio).thenReturn(dio);
  });

  group('login', () {
    test('should return TokenModel on successful login and store tokens', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'access_token': 'access-token',
          'refresh_token': 'refresh-token',
        },
      });
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => response);
      when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async => '');

      final result = await dataSource.login('test@test.com', 'password');

      expect(result.accessToken, 'access-token');
      expect(result.refreshToken, 'refresh-token');
    });
  });

  group('getCurrentUser', () {
    test('should return StaffModel on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'id': 1,
          'name': 'Dr. Smith',
          'email': 'smith@tezocare.com',
          'is_active': true,
        },
      });
      when(() => dio.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getCurrentUser();

      expect(result.id, 1);
      expect(result.name, 'Dr. Smith');
      expect(result.email, 'smith@tezocare.com');
    });
  });

  group('logout', () {
    test('should clear tokens from secure storage', () async {
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async => '');

      await dataSource.logout();

      verify(() => secureStorage.delete(key: any(named: 'key'))).called(2);
    });
  });
}
