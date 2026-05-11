import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final InternetConnectionChecker connectionChecker;
  final Logger logger;
  late final Dio _refreshDio;
  bool _isRefreshing = false;

  DioClient({
    required this.dio,
    required this.secureStorage,
    required this.connectionChecker,
    required this.logger,
  }) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = ApiConstants.connectTimeout;
    dio.options.receiveTimeout = ApiConstants.receiveTimeout;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isConnected = await connectionChecker.hasConnection;
        if (!isConnected) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: const NetworkException(
                message: 'No internet connection. Please check your network and try again.',
              ),
            ),
          );
        }
        final token = await secureStorage.read(
          key: ApiConstants.accessTokenKey,
        );
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.info(
          'REQUEST: ${options.method} ${options.uri}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        logger.info(
          'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}\n'
          'Data: ${response.data}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        logger.error(
          'ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}\n'
          'Message: ${error.message}',
        );
        handler.next(error);
      },
    );
  }

  Map<String, dynamic> _parseErrorResponse(Response? response) {
    if (response == null || response.data == null) {
      return {
        'message': 'An unexpected error occurred',
        'code': 'UNKNOWN_ERROR',
        'errors': <String, dynamic>{},
      };
    }

    final data = response.data;
    if (data is! Map) {
      return {
        'message': 'An unexpected error occurred',
        'code': 'UNKNOWN_ERROR',
        'errors': <String, dynamic>{},
      };
    }

    final message = data['message'] as String? ?? 'An error occurred';
    final code = data['code'] as String? ?? '';
    final errorsRaw = data['errors'];

    Map<String, dynamic> errorsMap = {};

    if (errorsRaw is List) {
      for (final error in errorsRaw) {
        if (error is Map) {
          final field = error['field'] as String? ??
              error['path'] as String? ??
              'error';
          final msg = error['message'] as String? ?? '';
          errorsMap[field] = msg;
        } else if (error is String) {
          errorsMap['error_${errorsMap.length}'] = error;
        }
      }
    } else if (errorsRaw is Map<String, dynamic>) {
      errorsMap = errorsRaw;
    }

    return {
      'message': message,
      'code': code,
      'errors': errorsMap,
    };
  }

  String _getReadableMessage(Map<String, dynamic> parsed) {
    final errors = parsed['errors'] as Map<String, dynamic>;
    if (errors.isNotEmpty) {
      return errors.values.first.toString();
    }
    return parsed['message'] as String;
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          handler.next(response);
        } else {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
        }
      },
      onError: (error, handler) async {
        final response = error.response;
        final parsed = _parseErrorResponse(response);
        final message = _getReadableMessage(parsed);
        final errors = parsed['errors'] as Map<String, dynamic>;
        final statusCode = response?.statusCode;

        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.unknown) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkException(
                message: 'No internet connection. Please check your network.',
              ),
            ),
          );
        }

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkException(
                message: 'Connection timed out. Please try again.',
              ),
            ),
          );
        }

        switch (statusCode) {
          case 400:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ServerException(message: message, statusCode: 400),
            ));
          case 401:
            final refreshed = await _attemptTokenRefresh(error.requestOptions);
            if (refreshed != null) {
              return handler.resolve(refreshed);
            }
            await _clearTokens();
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: UnauthorizedException(message: message),
            ));
          case 403:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: PermissionException(message: message),
            ));
          case 404:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: NotFoundException(message: message),
            ));
          case 409:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ConflictException(
                message: message,
                field: errors.keys.isNotEmpty ? errors.keys.first : null,
              ),
            ));
          case 422:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ValidationException(message: message, errors: errors),
            ));
          case 500:
          case 502:
          case 503:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ServerException(
                message: 'Server error. Please try again later.',
                statusCode: statusCode,
              ),
            ));
          default:
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ServerException(
                message: message,
                statusCode: statusCode,
              ),
            ));
        }
      },
    );
  }

  Future<Response?> _attemptTokenRefresh(
    RequestOptions originalRequestOptions,
  ) async {
    if (_isRefreshing) return null;

    if (originalRequestOptions.path.contains('/auth/refresh') ||
        originalRequestOptions.path.contains('/auth/login')) {
      return null;
    }

    _isRefreshing = true;
    try {
      final storedRefreshToken = await secureStorage.read(
        key: ApiConstants.refreshTokenKey,
      );

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        return null;
      }

      final refreshResponse = await _refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': storedRefreshToken},
      );

      final data =
          refreshResponse.data['data'] as Map<String, dynamic>? ??
          refreshResponse.data as Map<String, dynamic>;

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken == null) return null;

      await secureStorage.write(
        key: ApiConstants.accessTokenKey,
        value: newAccessToken,
      );
      if (newRefreshToken != null) {
        await secureStorage.write(
          key: ApiConstants.refreshTokenKey,
          value: newRefreshToken,
        );
      }

      originalRequestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await dio.fetch(originalRequestOptions);
      return retryResponse;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearTokens() async {
    await secureStorage.delete(key: ApiConstants.accessTokenKey);
    await secureStorage.delete(key: ApiConstants.refreshTokenKey);
  }
}
