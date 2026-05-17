import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalPatients,
    required super.visitsToday,
    required super.followUpsPending,
    required super.refillsDueSoon,
    super.recentPatients,
    super.upcomingRefills,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPatients: json['total_patients'] as int? ?? 0,
      visitsToday: json['visits_today'] as int? ?? 0,
      followUpsPending: json['follow_ups_pending'] as int? ?? 0,
      refillsDueSoon: json['refills_due_soon'] != null
          ? (json['refills_due_soon'] as List<dynamic>)
          : const [],
      recentPatients: json['recent_patients'] != null
          ? (json['recent_patients'] as List<dynamic>)
          : const [],
      upcomingRefills: json['upcoming_refills'] != null
          ? (json['upcoming_refills'] as List<dynamic>)
          : const [],
    );
  }
}
