import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;

  const ValidationFailure({
    required super.message,
    this.errors = const {},
  });

  @override
  List<Object> get props => [message, errors];
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class ConflictFailure extends Failure {
  final String? field;

  const ConflictFailure({required super.message, this.field});

  @override
  List<Object> get props => [message, field ?? ''];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
