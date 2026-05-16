import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
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
  Completer<void>? _refreshCompleter;

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
                message:
                    'No internet connection. Please check your network and try again.',
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
        'message': 'An unexpected error occurred in parseerror',
        'code': 'UNKNOWN_ERROR',
        'errors': <String, dynamic>{},
      };
    }

    final data = response.data;
    debugPrint(
      'Parsing error response: $data',
    ); // Debug print for raw error data
    debugPrint(
      'Parsed response: $response}',
    ); // Debug print for parsed error data
    debugPrint(
      'extracted error piece: ${response.data?['detail']?['message']}',
    );
    if (data is! Map) {
      return {
        'message': 'An unexpected error occurred, data not map',
        'code': 'UNKNOWN_ERROR',
        'errors': <String, dynamic>{},
      };
    }

    String message = 'An unexpected error occurred as a const string';
    String code = '';
    Map<String, dynamic> errorsMap = {};

    final detail = data['detail'];

    if (detail is Map) {
      // FastAPI HTTPException format
      message =
          detail['message'] as String? ??
          detail['detail'] as String? ??
          message;
      code = detail['code'] as String? ?? code;
    } else if (detail is String) {
      // FastAPI plain string detail
      message = detail;
    } else {
      // Standard TezoCare response format
      message = data['message'] as String? ?? message;
      code = data['code'] as String? ?? code;

      final errorsRaw = data['errors'];
      if (errorsRaw is List) {
        for (final error in errorsRaw) {
          if (error is Map) {
            final field = error['field'] as String? ?? 'error';
            final msg = error['message'] as String? ?? '';
            errorsMap[field] = msg;
          } else if (error is String) {
            errorsMap['error_${errorsMap.length}'] = error;
          }
        }
      } else if (errorsRaw is Map<String, dynamic>) {
        errorsMap = errorsRaw;
      }
    }

    if (message == 'An unexpected error occurred in the interceptor') {
      final detail = data['detail'];
      if (detail is Map && detail['message'] is String) {
        message = detail['message'] as String;
        code = detail['code'] as String? ?? code;
      }
    }

    return {'message': message, 'code': code, 'errors': errorsMap};
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
      onResponse: (response, handler) async {
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          handler.next(response);
          return;
        }

        final parsed = _parseErrorResponse(response);
        final message = _getReadableMessage(parsed);
        final statusCode = response.statusCode!;
        final errors = parsed['errors'] as Map<String, dynamic>;

        switch (statusCode) {
          case 400:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: ServerException(message: message, statusCode: 400),
              ),
            );
          case 401:
            if (response.requestOptions.path.contains('/auth/login') ||
                response.requestOptions.path.contains('/auth/register')) {
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: UnauthorizedException(message: message),
                ),
              );
            }
            final refreshed = await _attemptTokenRefresh(
              response.requestOptions,
            );
            if (refreshed != null) {
              return handler.resolve(refreshed);
            }
            await _clearTokens();
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: UnauthorizedException(message: message),
              ),
            );
          case 403:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: PermissionException(message: message),
              ),
            );
          case 404:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: NotFoundException(message: message),
              ),
            );
          case 409:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: ConflictException(
                  message: message,
                  field: errors.keys.isNotEmpty ? errors.keys.first : null,
                ),
              ),
            );
          case 422:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: ValidationException(message: message, errors: errors),
              ),
            );
          case 500:
          case 502:
          case 503:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: ServerException(
                  message: 'Server error. Please try again later.',
                  statusCode: statusCode,
                ),
              ),
            );
          default:
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: ServerException(
                  message: message,
                  statusCode: statusCode,
                ),
              ),
            );
        }
      },
      onError: (error, handler) async {
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

        handler.next(error);
      },
    );
  }

  Future<Response?> _attemptTokenRefresh(
    RequestOptions originalRequestOptions,
  ) async {
    if (originalRequestOptions.path.contains('/auth/refresh') ||
        originalRequestOptions.path.contains('/auth/login') ||
        originalRequestOptions.path.contains('/auth/register')) {
      return null;
    }

    if (_isRefreshing) {
      await _refreshCompleter?.future;
      final token = await secureStorage.read(
        key: ApiConstants.accessTokenKey,
      );
      if (token != null && token.isNotEmpty) {
        originalRequestOptions.headers['Authorization'] = 'Bearer $token';
        return dio.fetch(originalRequestOptions);
      }
      return null;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    try {
      final storedRefreshToken = await secureStorage.read(
        key: ApiConstants.refreshTokenKey,
      );

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        await _clearTokens();
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

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _clearTokens();
        return null;
      }

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

      originalRequestOptions.headers['Authorization'] =
          'Bearer $newAccessToken';
      final retryResponse = await dio.fetch(originalRequestOptions);
      return retryResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearTokens();
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete();
      }
    }
  }

  Future<void> _clearTokens() async {
    await secureStorage.delete(key: ApiConstants.accessTokenKey);
    await secureStorage.delete(key: ApiConstants.refreshTokenKey);
  }
}
