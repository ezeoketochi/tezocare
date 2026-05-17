import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.name,
    super.dosage,
    super.frequency,
    super.route,
    super.startDate,
    super.endDate,
    super.prescribedBy,
    super.notes,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as int,
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      name: json['name'] as String,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      route: json['route'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      prescribedBy: json['prescribed_by'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'prescribed_by': prescribedBy,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
