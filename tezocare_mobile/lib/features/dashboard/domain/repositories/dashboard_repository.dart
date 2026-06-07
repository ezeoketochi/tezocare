import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats({CancelToken? cancelToken});
  Future<DashboardStats?> getLocalDashboardStats();
  Future<void> saveLocalDashboardStats(DashboardStats stats);
}
