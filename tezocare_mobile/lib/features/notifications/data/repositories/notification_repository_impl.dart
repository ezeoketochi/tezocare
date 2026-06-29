import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;
  static const String _cacheKey = 'cached_notifications';

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, List<StaffNotification>>> getNotifications() async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getNotifications();
        final models = remote;
        await _cacheNotifications(models);
        return Right(models);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      } on UnauthorizedException {
        return Left(const UnauthorizedFailure(message: 'Session expired'));
      } on NetworkException {
        return _getCached();
      } catch (e) {
        return _getCached();
      }
    }
    return _getCached();
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAsRead(notificationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to mark as read'));
      }
    }
    return Left(const NetworkFailure(message: 'No internet connection'));
  }

  @override
  Future<List<StaffNotification>> getLocalNotifications() async {
    final cached = cacheService.getAs<List<dynamic>>(_cacheKey);
    if (cached == null) return [];
    return cached
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveLocalNotifications(List<StaffNotification> notifications) async {
    final jsonList = notifications
        .map((n) => (n as NotificationModel).toJson())
        .toList();
    cacheService.put(_cacheKey, jsonList);
  }

  Future<Either<Failure, List<StaffNotification>>> _getCached() async {
    final local = await getLocalNotifications();
    if (local.isNotEmpty) {
      return Right(local);
    }
    return Left(const NetworkFailure(message: 'No internet connection'));
  }

  Future<void> _cacheNotifications(List<NotificationModel> notifications) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    cacheService.put(_cacheKey, jsonList);
  }
}
