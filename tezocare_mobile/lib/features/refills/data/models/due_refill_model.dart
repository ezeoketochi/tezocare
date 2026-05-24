import '../../domain/entities/due_refill.dart';

class DueRefillModel extends DueRefill {
  const DueRefillModel({
    required super.refillId,
    required super.patientId,
    required super.patientName,
    super.patientPhone,
    required super.visitId,
    super.visitDate,
    super.drugName,
    super.dose,
    super.frequency,
    super.duration,
    super.dateDispensed,
    required super.refillDate,
    required super.daysUntilRefill,
    super.contactStatus,
    super.refillStatus,
    required super.escalatedStatus,
    super.lastActionAt,
    super.prescribedBy,
    super.isRecurrent,
    super.recurrenceIntervalDays,
  });

  factory DueRefillModel.fromJson(Map<String, dynamic> json) {
    return DueRefillModel(
      refillId: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? '',
      patientPhone: json['patient_phone'] as String?,
      visitId: json['visit_id'] as String,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      drugName: json['drug_name'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      dateDispensed: json['date_dispensed'] as String?,
      refillDate: json['refill_date'] as String? ?? '',
      daysUntilRefill: json['days_until_refill'] as int? ?? 0,
      contactStatus: json['contact_status'] as String? ?? 'pending',
      refillStatus: json['refill_status'] as String? ?? 'pending',
      escalatedStatus: json['escalated_status'] as String? ?? 'upcoming',
      lastActionAt: json['last_action_at'] != null
          ? DateTime.parse(json['last_action_at'] as String)
          : null,
      prescribedBy: json['prescribed_by'] as String?,
      isRecurrent: json['is_recurrent'] as bool? ?? false,
      recurrenceIntervalDays: json['recurrence_interval_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': refillId,
      'patient_id': patientId,
      'patient_name': patientName,
      if (patientPhone != null) 'patient_phone': patientPhone,
      'visit_id': visitId,
      if (visitDate != null)
        'visit_date': visitDate!.toIso8601String().split('T')[0],
      'drug_name': drugName,
      'dose': dose,
      'frequency': frequency,
      'duration': duration,
      if (dateDispensed != null) 'date_dispensed': dateDispensed,
      'refill_date': refillDate,
      'days_until_refill': daysUntilRefill,
      'contact_status': contactStatus,
      'refill_status': refillStatus,
      'escalated_status': escalatedStatus,
      if (lastActionAt != null)
        'last_action_at': lastActionAt!.toIso8601String(),
      if (prescribedBy != null) 'prescribed_by': prescribedBy,
      'is_recurrent': isRecurrent,
      if (recurrenceIntervalDays != null)
        'recurrence_interval_days': recurrenceIntervalDays,
    };
  }
}
