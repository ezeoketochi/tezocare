class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({required this.message});
}

class PermissionException implements Exception {
  final String message;

  const PermissionException({required this.message});
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});
}

class ConflictException implements Exception {
  final String message;
  final String? field;

  const ConflictException({required this.message, this.field});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> errors;

  const ValidationException({
    required this.message,
    this.errors = const {},
  });
}
