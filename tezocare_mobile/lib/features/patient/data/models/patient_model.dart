import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.dateOfBirth,
    required super.gender,
    super.phone,
    super.address,
    super.state,
    super.city,
    super.occupation,
    super.bloodGroup,
    super.genotype,
    super.allergies,
    super.chronicConditions,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.registeredBy,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String? ?? 'male',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      occupation: json['occupation'] as String?,
      bloodGroup: json['blood_group'] as String?,
      genotype: json['genotype'] as String?,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : const [],
      chronicConditions: json['chronic_conditions'] != null
          ? List<String>.from(json['chronic_conditions'] as List)
          : const [],
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      registeredBy: json['registered_by'] as String?,
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
      'first_name': firstName,
      'last_name': lastName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      'gender': gender,
      'phone': phone,
      'address': address,
      'state': state,
      'city': city,
      'occupation': occupation,
      'blood_group': bloodGroup,
      'genotype': genotype,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
    };
  }
}
