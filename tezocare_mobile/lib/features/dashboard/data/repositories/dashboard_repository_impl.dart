import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats({CancelToken? cancelToken}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getDashboardStats(cancelToken: cancelToken);
      await saveLocalDashboardStats(result);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<DashboardStats?> getLocalDashboardStats() async {
    return cacheService.getAs<DashboardStats>('dashboard_stats');
  }

  @override
  Future<void> saveLocalDashboardStats(DashboardStats stats) async {
    cacheService.put('dashboard_stats', stats);
  }
}
