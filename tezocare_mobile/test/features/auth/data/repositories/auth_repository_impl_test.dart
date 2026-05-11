import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/exceptions.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/network/network_info.dart';
import 'package:tezocare_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tezocare_mobile/features/auth/data/models/staff_model.dart';
import 'package:tezocare_mobile/features/auth/data/models/token_model.dart';
import 'package:tezocare_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('login', () {
    const token = TokenModel(accessToken: 'access', refreshToken: 'refresh');

    test('should return Token on success', () async {
      when(() => remoteDataSource.login(any(), any())).thenAnswer((_) async => token);

      final result = await repository.login('test@test.com', 'password');

      expect(result, Right(token));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login('test@test.com', 'password');

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });

    test('should return UnauthorizedFailure on UnauthorizedException', () async {
      when(() => remoteDataSource.login(any(), any())).thenThrow(
        const UnauthorizedException(message: 'Bad credentials'),
      );

      final result = await repository.login('test@test.com', 'password');

      expect(result, Left(UnauthorizedFailure(message: 'Bad credentials')));
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => remoteDataSource.login(any(), any())).thenThrow(
        const ServerException(message: 'Server error', statusCode: 500),
      );

      final result = await repository.login('test@test.com', 'password');

      expect(result, Left(ServerFailure(message: 'Server error', statusCode: 500)));
    });
  });

  group('getCurrentUser', () {
    const staff = StaffModel(id: '1', name: 'Dr. Smith', email: 'smith@tezocare.com', isActive: true);

    test('should return Staff on success', () async {
      when(() => remoteDataSource.getCurrentUser()).thenAnswer((_) async => staff);

      final result = await repository.getCurrentUser();

      expect(result, const Right(staff));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getCurrentUser();

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });

    test('should return UnauthorizedFailure on UnauthorizedException', () async {
      when(() => remoteDataSource.getCurrentUser()).thenThrow(
        const UnauthorizedException(message: 'Not authenticated'),
      );

      final result = await repository.getCurrentUser();

      expect(result, Left(UnauthorizedFailure(message: 'Not authenticated')));
    });
  });

  group('refreshToken', () {
    const token = TokenModel(accessToken: 'new-access', refreshToken: 'new-refresh');

    test('should return Token on success', () async {
      when(() => remoteDataSource.refreshToken(any())).thenAnswer((_) async => token);

      final result = await repository.refreshToken('refresh');

      expect(result, Right(token));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.refreshToken('refresh');

      expect(result, Left(NetworkFailure(message: 'No internet connection')));
    });
  });

  group('logout', () {
    test('should return Right(null) on success', () async {
      when(() => remoteDataSource.logout()).thenAnswer((_) async => Future.value());

      final result = await repository.logout();

      expect(result, const Right(null));
    });
  });
}
