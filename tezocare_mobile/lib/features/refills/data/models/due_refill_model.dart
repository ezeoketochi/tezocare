import '../../domain/entities/due_refill.dart';

class DueRefillModel extends DueRefill {
  const DueRefillModel({
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
    required super.refillStatus,
    super.prescribedBy,
  });

  factory DueRefillModel.fromJson(Map<String, dynamic> json) {
    return DueRefillModel(
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
      refillStatus: json['refill_status'] as String? ?? 'upcoming',
      prescribedBy: json['prescribed_by'] as String?,
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
      'drug_name': drugName,
      'dose': dose,
      'frequency': frequency,
      'duration': duration,
      if (dateDispensed != null) 'date_dispensed': dateDispensed,
      'refill_date': refillDate,
      'days_until_refill': daysUntilRefill,
      'refill_status': refillStatus,
      if (prescribedBy != null) 'prescribed_by': prescribedBy,
    };
  }
}
