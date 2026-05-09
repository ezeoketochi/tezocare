import 'package:equatable/equatable.dart';
import '../../domain/entities/staff.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final Staff staff;

  const AuthAuthenticated({required this.staff});

  @override
  List<Object> get props => [staff];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthValidationError extends AuthState {
  final Map<String, dynamic> errors;

  const AuthValidationError({required this.errors});

  @override
  List<Object> get props => [errors];
}
