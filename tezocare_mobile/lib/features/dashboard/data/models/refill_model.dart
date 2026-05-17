import '../../domain/entities/refill.dart';

class RefillModel extends Refill {
  const RefillModel({
    required super.id,
    required super.medicationId,
    required super.medicationName,
    required super.patientId,
    required super.patientName,
    super.lastRefillDate,
    super.nextRefillDate,
    required super.isOverdue,
  });

  factory RefillModel.fromJson(Map<String, dynamic> json) {
    return RefillModel(
      id: json['id'] as String,
      medicationId: json['medication_id'] as String,
      medicationName: json['medication_name'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      lastRefillDate: json['last_refill_date'] != null
          ? DateTime.parse(json['last_refill_date'] as String)
          : null,
      nextRefillDate: json['next_refill_date'] != null
          ? DateTime.parse(json['next_refill_date'] as String)
          : null,
      isOverdue: json['is_overdue'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_id': medicationId,
      'medication_name': medicationName,
      'patient_id': patientId,
      'patient_name': patientName,
      if (lastRefillDate != null) 'last_refill_date': lastRefillDate!.toIso8601String(),
      if (nextRefillDate != null) 'next_refill_date': nextRefillDate!.toIso8601String(),
      'is_overdue': isOverdue,
    };
  }
}
