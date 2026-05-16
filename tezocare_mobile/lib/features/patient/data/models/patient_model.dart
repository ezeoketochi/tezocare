import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.fullName,
    required super.dob,
    required super.gender,
    super.bloodGroup,
    required super.phone,
    super.address,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.allergies,
    super.chronicConditions,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
    super.medications,
    super.vitals,
    super.nextRefill,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      dob: DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String,
      bloodGroup: json['blood_group'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      allergies: json['allergies'] as String?,
      chronicConditions: json['chronic_conditions'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => MedicationInfo(
                    id: e['id'] as String,
                    drugName: e['drug_name'] as String,
                    dosage: e['dosage'] as String,
                    frequency: e['frequency'] as String,
                    startDate: DateTime.parse(e['start_date'] as String),
                    endDate: e['end_date'] != null
                        ? DateTime.parse(e['end_date'] as String)
                        : null,
                    nextRefillDate: e['next_refill_date'] != null
                        ? DateTime.parse(e['next_refill_date'] as String)
                        : null,
                    isActive: e['is_active'] as bool? ?? true,
                    prescribedBy: e['prescribed_by'] as String?,
                    notes: e['notes'] as String?,
                  ))
              .toList() ??
          [],
      vitals: (json['vitals'] as List<dynamic>?)
              ?.map((e) => VitalSigns(
                    id: e['id'] as String,
                    bloodPressureSystolic:
                        e['blood_pressure_systolic'] as int?,
                    bloodPressureDiastolic:
                        e['blood_pressure_diastolic'] as int?,
                    glucose: (e['glucose'] as num?)?.toDouble(),
                    temperature: (e['temperature'] as num?)?.toDouble(),
                    weight: (e['weight'] as num?)?.toDouble(),
                    heartRate: e['heart_rate'] as int?,
                    spo2: e['spo2'] as int?,
                    recordedAt: e['recorded_at'] != null
                        ? DateTime.parse(e['recorded_at'] as String)
                        : null,
                  ))
              .toList() ??
          [],
      nextRefill: json['next_refill'] != null
          ? RefillInfo(
              drugName: json['next_refill']['drug_name'] as String,
              nextRefillDate: DateTime.parse(
                  json['next_refill']['next_refill_date'] as String),
              dosage: json['next_refill']['dosage'] as String,
              frequency: json['next_refill']['frequency'] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'dob': dob.toIso8601String().split('T')[0],
      'gender': gender,
      'blood_group': bloodGroup,
      'phone': phone,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'is_active': isActive,
    };
  }
}
