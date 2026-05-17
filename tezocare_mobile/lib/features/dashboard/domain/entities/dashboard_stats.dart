import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalPatients;
  final int visitsToday;
  final int followUpsPending;
  final int refillsDueSoon;
  final List<dynamic> recentPatients;
  final List<dynamic> upcomingRefills;

  const DashboardStats({
    required this.totalPatients,
    required this.visitsToday,
    required this.followUpsPending,
    required this.refillsDueSoon,
    this.recentPatients = const [],
    this.upcomingRefills = const [],
  });

  @override
  List<Object> get props => [
        totalPatients,
        visitsToday,
        followUpsPending,
        refillsDueSoon,
        recentPatients,
        upcomingRefills,
      ];
}
