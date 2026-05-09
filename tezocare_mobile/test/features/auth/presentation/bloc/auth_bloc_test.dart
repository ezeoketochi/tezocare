import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/core/usecases/usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/staff.dart';
import 'package:tezocare_mobile/features/auth/domain/entities/token.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tezocare_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:tezocare_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tezocare_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:tezocare_mobile/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockRefreshTokenUseCase refreshTokenUseCase;

  setUp(() {
    loginUseCase = MockLoginUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    refreshTokenUseCase = MockRefreshTokenUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
    registerFallbackValue(const RefreshTokenParams(refreshToken: ''));
  });

  const staff = Staff(id: 1, name: 'Dr. Smith', email: 'smith@tezocare.com', isActive: true);
  const token = Token(accessToken: 'access', refreshToken: 'refresh');

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when login succeeds',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => const Right(token),
        );
        when(() => getCurrentUserUseCase(any())).thenAnswer(
          (_) async => const Right(staff),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@test.com', password: 'password',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(staff: staff),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] when login fails with ServerFailure',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@test.com', password: 'password',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Server error'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when login fails with UnauthorizedFailure',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => Left(UnauthorizedFailure(message: 'Bad credentials')),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@test.com', password: 'password',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when logout succeeds',
      build: () {
        when(() => logoutUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when checkAuth succeeds',
      build: () {
        when(() => getCurrentUserUseCase(any())).thenAnswer(
          (_) async => const Right(staff),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthAuthenticated(staff: staff),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when checkAuth returns UnauthorizedFailure',
      build: () {
        when(() => getCurrentUserUseCase(any())).thenAnswer(
          (_) async => Left(UnauthorizedFailure(message: 'Not authenticated')),
        );
        return AuthBloc(
          loginUseCase: loginUseCase,
          logoutUseCase: logoutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          refreshTokenUseCase: refreshTokenUseCase,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );
  });
}
