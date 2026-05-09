import '../../domain/entities/visit.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.staffId,
    super.staffName,
    required super.visitDate,
    super.reason,
    super.diagnosis,
    super.treatment,
    super.notes,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as int,
      patientId: json['patient_id'] as int,
      patientName: json['patient_name'] as String?,
      staffId: json['staff_id'] as int,
      staffName: json['staff_name'] as String?,
      visitDate: DateTime.parse(json['visit_date'] as String),
      reason: json['reason'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'staff_id': staffId,
      'staff_name': staffName,
      'visit_date': visitDate.toIso8601String(),
      'reason': reason,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
