import 'package:equatable/equatable.dart';

class Visit extends Equatable {
  final int id;
  final int patientId;
  final String? patientName;
  final int staffId;
  final String? staffName;
  final DateTime visitDate;
  final String? reason;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Visit({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.staffId,
    this.staffName,
    required this.visitDate,
    this.reason,
    this.diagnosis,
    this.treatment,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        staffId,
        staffName,
        visitDate,
        reason,
        diagnosis,
        treatment,
        notes,
        status,
        createdAt,
        updatedAt,
      ];
}
