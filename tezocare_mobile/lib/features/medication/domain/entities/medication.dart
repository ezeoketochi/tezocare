import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String patientId;
  final String? patientName;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? route;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medication({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.route,
    this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Medication copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        name,
        dosage,
        frequency,
        duration,
        route,
        startDate,
        endDate,
        prescribedBy,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];
}
