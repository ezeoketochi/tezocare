import 'package:equatable/equatable.dart';

class DueFollowUp extends Equatable {
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String visitId;
  final DateTime? visitDate;
  final String scheduledDate;
  final int daysUntilFollowup;
  final String followupStatus;
  final String? outcome;
  final String? suspectedDiagnosis;
  final List<MedicationDispensedInfo> medicationsDispensed;
  final String? attendingStaff;

  const DueFollowUp({
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.visitId,
    this.visitDate,
    required this.scheduledDate,
    required this.daysUntilFollowup,
    required this.followupStatus,
    this.outcome,
    this.suspectedDiagnosis,
    this.medicationsDispensed = const [],
    this.attendingStaff,
  });

  DueFollowUp copyWith({
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? visitId,
    DateTime? visitDate,
    String? scheduledDate,
    int? daysUntilFollowup,
    String? followupStatus,
    String? outcome,
    String? suspectedDiagnosis,
    List<MedicationDispensedInfo>? medicationsDispensed,
    String? attendingStaff,
  }) {
    return DueFollowUp(
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      visitId: visitId ?? this.visitId,
      visitDate: visitDate ?? this.visitDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      daysUntilFollowup: daysUntilFollowup ?? this.daysUntilFollowup,
      followupStatus: followupStatus ?? this.followupStatus,
      outcome: outcome ?? this.outcome,
      suspectedDiagnosis: suspectedDiagnosis ?? this.suspectedDiagnosis,
      medicationsDispensed: medicationsDispensed ?? this.medicationsDispensed,
      attendingStaff: attendingStaff ?? this.attendingStaff,
    );
  }

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        patientPhone,
        visitId,
        visitDate,
        scheduledDate,
        daysUntilFollowup,
        followupStatus,
        outcome,
        suspectedDiagnosis,
        medicationsDispensed,
        attendingStaff,
      ];
}

class MedicationDispensedInfo extends Equatable {
  final String drugName;
  final String dose;
  final String frequency;

  const MedicationDispensedInfo({
    this.drugName = '',
    this.dose = '',
    this.frequency = '',
  });

  @override
  List<Object?> get props => [drugName, dose, frequency];
}
