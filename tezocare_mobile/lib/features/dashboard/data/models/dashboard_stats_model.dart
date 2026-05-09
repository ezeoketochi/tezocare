import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalPatients,
    required super.activeVisits,
    required super.todayAppointments,
    required super.pendingRefills,
    required super.totalStaff,
    required super.medicationsActive,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPatients: json['total_patients'] as int? ?? 0,
      activeVisits: json['active_visits'] as int? ?? 0,
      todayAppointments: json['today_appointments'] as int? ?? 0,
      pendingRefills: json['pending_refills'] as int? ?? 0,
      totalStaff: json['total_staff'] as int? ?? 0,
      medicationsActive: json['medications_active'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patients': totalPatients,
      'active_visits': activeVisits,
      'today_appointments': todayAppointments,
      'pending_refills': pendingRefills,
      'total_staff': totalStaff,
      'medications_active': medicationsActive,
    };
  }
}
