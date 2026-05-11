import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

Either<Failure, T> handleException<T>(Object e) {
  if (e is DioException && e.error != null) {
    final error = e.error;
    if (error is ValidationException) {
      return Left(ValidationFailure(
        message: error.message,
        errors: error.errors,
      ));
    }
    if (error is UnauthorizedException) {
      return Left(UnauthorizedFailure(message: error.message));
    }
    if (error is PermissionException) {
      return Left(PermissionFailure(message: error.message));
    }
    if (error is NotFoundException) {
      return Left(NotFoundFailure(message: error.message));
    }
    if (error is ConflictException) {
      return Left(ConflictFailure(
        message: error.message,
        field: error.field,
      ));
    }
    if (error is NetworkException) {
      return Left(NetworkFailure(message: error.message));
    }
    if (error is ServerException) {
      return Left(ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
      ));
    }
  }
  if (e is ValidationException) {
    return Left(ValidationFailure(
      message: e.message,
      errors: e.errors,
    ));
  }
  if (e is NetworkException) {
    return Left(NetworkFailure(message: e.message));
  }
  if (e is ServerException) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  }
  return Left(ServerFailure(
    message: 'An unexpected error occurred. Please try again.',
  ));
}
