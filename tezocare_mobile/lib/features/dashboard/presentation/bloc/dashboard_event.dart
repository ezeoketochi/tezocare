import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class GetDashboardStatsEvent extends DashboardEvent {
  const GetDashboardStatsEvent();
}
