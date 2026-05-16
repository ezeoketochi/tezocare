import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String fullName;
  final DateTime dob;
  final String gender;
  final String? bloodGroup;
  final String phone;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? allergies;
  final String? chronicConditions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MedicationInfo> medications;
  final List<VitalSigns> vitals;
  final RefillInfo? nextRefill;

  const Patient({
    required this.id,
    required this.fullName,
    required this.dob,
    required this.gender,
    this.bloodGroup,
    required this.phone,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.allergies,
    this.chronicConditions,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.medications = const [],
    this.vitals = const [],
    this.nextRefill,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    dob,
    gender,
    bloodGroup,
    phone,
    address,
    emergencyContactName,
    emergencyContactPhone,
    allergies,
    chronicConditions,
    isActive,
    createdAt,
    updatedAt,
    medications,
    vitals,
    nextRefill,
  ];
}

class MedicationInfo extends Equatable {
  final String id;
  final String drugName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextRefillDate;
  final bool isActive;
  final String? prescribedBy;
  final String? notes;

  const MedicationInfo({
    required this.id,
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.nextRefillDate,
    required this.isActive,
    this.prescribedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id, drugName, dosage, frequency, startDate, endDate,
    nextRefillDate, isActive, prescribedBy, notes,
  ];
}

class VitalSigns extends Equatable {
  final String id;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? glucose;
  final double? temperature;
  final double? weight;
  final int? heartRate;
  final int? spo2;
  final DateTime? recordedAt;

  const VitalSigns({
    required this.id,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.glucose,
    this.temperature,
    this.weight,
    this.heartRate,
    this.spo2,
    this.recordedAt,
  });

  @override
  List<Object?> get props => [
    id, bloodPressureSystolic, bloodPressureDiastolic, glucose,
    temperature, weight, heartRate, spo2, recordedAt,
  ];
}

class RefillInfo extends Equatable {
  final String drugName;
  final DateTime nextRefillDate;
  final String dosage;
  final String frequency;

  const RefillInfo({
    required this.drugName,
    required this.nextRefillDate,
    required this.dosage,
    required this.frequency,
  });

  @override
  List<Object?> get props => [drugName, nextRefillDate, dosage, frequency];
}
