import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalPatients;
  final int activeVisits;
  final int todayAppointments;
  final int pendingRefills;
  final int totalStaff;
  final int medicationsActive;

  const DashboardStats({
    required this.totalPatients,
    required this.activeVisits,
    required this.todayAppointments,
    required this.pendingRefills,
    required this.totalStaff,
    required this.medicationsActive,
  });

  @override
  List<Object> get props => [
        totalPatients,
        activeVisits,
        todayAppointments,
        pendingRefills,
        totalStaff,
        medicationsActive,
      ];
}
