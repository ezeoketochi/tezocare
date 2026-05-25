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
    super.doseAmount,
    super.doseUnit,
    super.route,
    super.frequency,
    super.frequencyCode,
    super.durationAmount,
    super.durationUnit,
    super.totalQuantity,
    super.instructions,
    super.sigString,
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
      doseAmount: (json['dose_amount'] as num?)?.toDouble(),
      doseUnit: json['dose_unit'] as String?,
      route: json['route'] as String?,
      frequency: json['frequency'] as String? ?? '',
      frequencyCode: json['frequency_code'] as String?,
      durationAmount: json['duration_amount'] as int?,
      durationUnit: json['duration_unit'] as String?,
      totalQuantity: json['total_quantity'] as int?,
      instructions: json['instructions'] as String?,
      sigString: json['sig_string'] as String?,
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
      if (doseAmount != null) 'dose_amount': doseAmount,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (route != null) 'route': route,
      'frequency': frequency,
      if (frequencyCode != null) 'frequency_code': frequencyCode,
      if (durationAmount != null) 'duration_amount': durationAmount,
      if (durationUnit != null) 'duration_unit': durationUnit,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (instructions != null) 'instructions': instructions,
      if (sigString != null) 'sig_string': sigString,
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
