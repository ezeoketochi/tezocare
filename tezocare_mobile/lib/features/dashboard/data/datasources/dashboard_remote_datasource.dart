import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.dashboardSummary);
      return DashboardStatsModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to fetch dashboard stats',
      );
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
