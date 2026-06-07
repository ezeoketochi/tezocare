import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase implements UseCase<DashboardStats, GetDashboardStatsParams> {
  final DashboardRepository repository;

  GetDashboardStatsUseCase({required this.repository});

  @override
  Future<Either<Failure, DashboardStats>> call(GetDashboardStatsParams params) {
    return repository.getDashboardStats(cancelToken: params.cancelToken);
  }
}

class GetDashboardStatsParams {
  final CancelToken? cancelToken;

  const GetDashboardStatsParams({this.cancelToken});
}
