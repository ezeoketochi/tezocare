import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final Logger logger;
  late final Dio _refreshDio;
  bool _isRefreshing = false;

  DioClient({
    required this.dio,
    required this.secureStorage,
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
        final token = await secureStorage.read(key: ApiConstants.accessTokenKey);
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
        if (error.response == null) {
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkException(message: 'No internet connection'),
                type: DioExceptionType.unknown,
              ),
            );
            return;
          }
          handler.next(error);
          return;
        }

        final statusCode = error.response!.statusCode;
        if (statusCode == null) {
          handler.next(error);
          return;
        }

        switch (statusCode) {
          case 401:
            await _handleUnauthorized(error, handler);
            return;
          case 403:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: PermissionException(
                  message: _extractMessage(error.response?.data) ??
                      'Access forbidden',
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          case 404:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: NotFoundException(
                  message: _extractMessage(error.response?.data) ??
                      'Resource not found',
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          case 422:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: ValidationException(
                  message: _extractMessage(error.response?.data) ??
                      'Validation failed',
                  errors: error.response?.data?['errors']
                      as Map<String, dynamic>?,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          case >= 500:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: ServerException(
                  message: _extractMessage(error.response?.data) ??
                      'Server error occurred',
                  statusCode: statusCode,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          default:
            handler.next(error);
        }
      },
    );
  }

  Future<void> _handleUnauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      handler.next(error);
      return;
    }

    if (error.requestOptions.path.contains('/auth/refresh') ||
        error.requestOptions.path.contains('/auth/login')) {
      await _clearTokens();
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: const UnauthorizedException(message: 'Session expired'),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    _isRefreshing = true;
    try {
      final storedRefreshToken =
          await secureStorage.read(key: ApiConstants.refreshTokenKey);

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        await _clearTokens();
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: const UnauthorizedException(message: 'No refresh token available'),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      final refreshResponse = await _refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': storedRefreshToken},
      );

      final data = refreshResponse.data['data'] as Map<String, dynamic>? ??
          refreshResponse.data as Map<String, dynamic>;

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken == null) {
        await _clearTokens();
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: const UnauthorizedException(message: 'Token refresh failed'),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
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

      error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await dio.fetch(error.requestOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      await _clearTokens();
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: const UnauthorizedException(message: 'Session expired'),
          type: DioExceptionType.badResponse,
        ),
      );
    } finally {
      _isRefreshing = false;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['detail'] as String?;
    }
    return null;
  }

  Future<void> _clearTokens() async {
    await secureStorage.delete(key: ApiConstants.accessTokenKey);
    await secureStorage.delete(key: ApiConstants.refreshTokenKey);
  }
}
