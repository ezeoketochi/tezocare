import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.staffNotifications,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final notifications = data['notifications'] as List<dynamic>;
      return notifications
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch notifications');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.staffNotifications,
        queryParameters: {'limit': 1, 'skip': 0},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['unread_count'] as int;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch unread count');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await dioClient.dio.patch(
        '${ApiConstants.staffNotifications}/$notificationId/read',
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to mark notification as read');
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
