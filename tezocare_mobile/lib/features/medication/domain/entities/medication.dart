import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String patientId;
  final String? patientName;
  final String name;
  final String? dosage;
  final String? frequency;
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
    this.route,
    this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        name,
        dosage,
        frequency,
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
