import '../../domain/entities/refill.dart';

class RefillModel extends Refill {
  const RefillModel({
    required super.id,
    required super.medicationId,
    required super.medicationName,
    required super.patientId,
    required super.patientName,
    required super.lastRefillDate,
    required super.nextRefillDate,
    required super.isOverdue,
  });

  factory RefillModel.fromJson(Map<String, dynamic> json) {
    return RefillModel(
      id: json['id'] as int,
      medicationId: json['medication_id'] as int,
      medicationName: json['medication_name'] as String,
      patientId: json['patient_id'] as int,
      patientName: json['patient_name'] as String,
      lastRefillDate: DateTime.parse(json['last_refill_date'] as String),
      nextRefillDate: DateTime.parse(json['next_refill_date'] as String),
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
      'last_refill_date': lastRefillDate.toIso8601String(),
      'next_refill_date': nextRefillDate.toIso8601String(),
      'is_overdue': isOverdue,
    };
  }
}
