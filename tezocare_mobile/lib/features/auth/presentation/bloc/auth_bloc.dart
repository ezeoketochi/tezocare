import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.refreshTokenUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthRefreshRequested>(_onRefreshToken);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    await result.fold(
      (failure) async => _mapFailureToState(failure, emit),
      (token) async {
        final userResult = await getCurrentUserUseCase(const NoParams());
        userResult.fold(
          (failure) => _mapFailureToState(failure, emit),
          (staff) => emit(AuthAuthenticated(staff: staff)),
        );
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuth(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure || failure is PermissionFailure) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (staff) => emit(AuthAuthenticated(staff: staff)),
    );
  }

  Future<void> _onRefreshToken(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await refreshTokenUseCase(
      RefreshTokenParams(refreshToken: event.refreshToken),
    );
    await result.fold(
      (failure) async => _mapFailureToState(failure, emit),
      (token) async {
        final userResult = await getCurrentUserUseCase(const NoParams());
        userResult.fold(
          (failure) => _mapFailureToState(failure, emit),
          (staff) => emit(AuthAuthenticated(staff: staff)),
        );
      },
    );
  }

  void _mapFailureToState(Failure failure, Emitter<AuthState> emit) {
    if (failure is UnauthorizedFailure || failure is PermissionFailure) {
      emit(const AuthUnauthenticated());
    } else if (failure is ValidationFailure) {
      emit(AuthValidationError(errors: failure.errors ?? {}));
    } else {
      emit(AuthError(message: failure.message));
    }
  }
}
