import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/due_follow_up_model.dart';

abstract class FollowUpRemoteDataSource {
  Future<List<DueFollowUpModel>> getDueFollowUps({String? filter, int? days, CancelToken? cancelToken});
  Future<Map<String, dynamic>> markFollowUpDone(String visitId, {required String outcome});
}

class FollowUpRemoteDataSourceImpl implements FollowUpRemoteDataSource {
  final DioClient dioClient;

  FollowUpRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DueFollowUpModel>> getDueFollowUps({String? filter, int? days, CancelToken? cancelToken}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filter != null) queryParams['filter'] = filter;
      if (days != null) queryParams['days'] = days;
      final response = await dioClient.dio.get(
        ApiConstants.dashboardDueFollowUps,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        cancelToken: cancelToken,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final followups = data['followups'] as List<dynamic>;
      return followups
          .map((e) => DueFollowUpModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch due follow-ups');
    }
  }

  @override
  Future<Map<String, dynamic>> markFollowUpDone(String visitId, {required String outcome}) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.visits}/$visitId/followup-done',
        data: {'outcome': outcome},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to mark follow-up done');
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
