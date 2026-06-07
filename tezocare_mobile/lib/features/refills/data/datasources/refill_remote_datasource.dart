import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/due_refill_model.dart';

abstract class RefillRemoteDataSource {
  Future<List<DueRefillModel>> getDueRefills({String? filter, int? days, CancelToken? cancelToken});
  Future<Map<String, dynamic>> markContacted(String refillId);
  Future<Map<String, dynamic>> markRefilled(String refillId);
  Future<Map<String, dynamic>> createRefillsBatch(List<Map<String, dynamic>> medications);
}

class RefillRemoteDataSourceImpl implements RefillRemoteDataSource {
  final DioClient dioClient;

  RefillRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DueRefillModel>> getDueRefills({String? filter, int? days, CancelToken? cancelToken}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filter != null) queryParams['filter'] = filter;
      if (days != null) queryParams['days'] = days;
      final response = await dioClient.dio.get(
        ApiConstants.refills,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        cancelToken: cancelToken,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final refills = data['refills'] as List<dynamic>;
      return refills
          .map((e) => DueRefillModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch due refills');
    }
  }

  @override
  Future<Map<String, dynamic>> markContacted(String refillId) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.refills}/$refillId/contact',
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to mark refill as contacted');
    }
  }

  @override
  Future<Map<String, dynamic>> markRefilled(String refillId) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.refills}/$refillId/fulfill',
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to mark refill as fulfilled');
    }
  }

  @override
  Future<Map<String, dynamic>> createRefillsBatch(
    List<Map<String, dynamic>> medications,
  ) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiConstants.refills}/batch',
        data: medications,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to create refills');
    }
  }

  Exception _mapDioException(DioException e, {required String defaultMessage}) {
    final customException = e.error;
    if (customException is UnauthorizedException) return customException;
    if (customException is ValidationException) return customException;
    if (customException is PermissionException) return customException;
    if (customException is NotFoundException) return customException;
    if (customException is NetworkException) return customException;

    return ServerException(
      message: e.response?.data['message'] as String? ??
          e.response?.data['detail'] as String? ??
          defaultMessage,
      statusCode: e.response?.statusCode,
    );
  }
}
