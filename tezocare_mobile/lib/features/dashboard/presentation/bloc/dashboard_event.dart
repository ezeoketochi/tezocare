import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class GetDashboardStatsEvent extends DashboardEvent {
  final CancelToken? cancelToken;

  const GetDashboardStatsEvent({this.cancelToken});

  @override
  List<Object?> get props => [cancelToken];
}
