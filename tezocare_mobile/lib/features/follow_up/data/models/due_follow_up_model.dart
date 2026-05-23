import '../../domain/entities/due_follow_up.dart';

class DueFollowUpModel extends DueFollowUp {
  const DueFollowUpModel({
    required super.patientId,
    required super.patientName,
    super.patientPhone,
    required super.visitId,
    super.visitDate,
    required super.scheduledDate,
    required super.daysUntilFollowup,
    required super.followupStatus,
    super.outcome,
    super.suspectedDiagnosis,
    super.medicationsDispensed,
    super.attendingStaff,
  });

  factory DueFollowUpModel.fromJson(Map<String, dynamic> json) {
    return DueFollowUpModel(
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? '',
      patientPhone: json['patient_phone'] as String?,
      visitId: json['visit_id'] as String,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      scheduledDate: json['scheduled_date'] as String? ?? '',
      daysUntilFollowup: json['days_until_followup'] as int? ?? 0,
      followupStatus: json['followup_status'] as String? ?? 'upcoming',
      outcome: json['outcome'] as String?,
      suspectedDiagnosis: json['suspected_diagnosis'] as String?,
      medicationsDispensed: json['medications_dispensed'] != null
          ? (json['medications_dispensed'] as List<dynamic>)
              .map((e) => MedicationDispensedInfoModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      attendingStaff: json['attending_staff'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      if (patientPhone != null) 'patient_phone': patientPhone,
      'visit_id': visitId,
      if (visitDate != null)
        'visit_date': visitDate!.toIso8601String().split('T')[0],
      'scheduled_date': scheduledDate,
      'days_until_followup': daysUntilFollowup,
      'followup_status': followupStatus,
      if (outcome != null) 'outcome': outcome,
      if (suspectedDiagnosis != null)
        'suspected_diagnosis': suspectedDiagnosis,
      if (medicationsDispensed.isNotEmpty)
        'medications_dispensed':
            medicationsDispensed.map((e) => (e as MedicationDispensedInfoModel).toJson()).toList(),
      if (attendingStaff != null) 'attending_staff': attendingStaff,
    };
  }
}

class MedicationDispensedInfoModel extends MedicationDispensedInfo {
  const MedicationDispensedInfoModel({
    super.drugName,
    super.dose,
    super.frequency,
  });

  factory MedicationDispensedInfoModel.fromJson(Map<String, dynamic> json) {
    return MedicationDispensedInfoModel(
      drugName: json['drug_name'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_name': drugName,
      'dose': dose,
      'frequency': frequency,
    };
  }
}
