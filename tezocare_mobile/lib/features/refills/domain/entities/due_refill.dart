import 'package:equatable/equatable.dart';

class DueRefill extends Equatable {
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String visitId;
  final DateTime? visitDate;
  final String drugName;
  final String dose;
  final String frequency;
  final String duration;
  final String? dateDispensed;
  final String refillDate;
  final int daysUntilRefill;
  final String refillStatus;
  final String? prescribedBy;

  const DueRefill({
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.visitId,
    this.visitDate,
    this.drugName = '',
    this.dose = '',
    this.frequency = '',
    this.duration = '',
    this.dateDispensed,
    required this.refillDate,
    required this.daysUntilRefill,
    required this.refillStatus,
    this.prescribedBy,
  });

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        patientPhone,
        visitId,
        visitDate,
        drugName,
        dose,
        frequency,
        duration,
        dateDispensed,
        refillDate,
        daysUntilRefill,
        refillStatus,
        prescribedBy,
      ];
}
