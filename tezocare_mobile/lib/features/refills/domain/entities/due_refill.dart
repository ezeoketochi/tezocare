import 'package:equatable/equatable.dart';

class DueRefill extends Equatable {
  final String refillId;
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
  final String contactStatus;
  final String refillStatus;
  final String escalatedStatus;
  final DateTime? lastActionAt;
  final String? prescribedBy;
  final bool isRecurrent;
  final int? recurrenceIntervalDays;

  const DueRefill({
    required this.refillId,
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
    this.contactStatus = 'pending',
    this.refillStatus = 'pending',
    required this.escalatedStatus,
    this.lastActionAt,
    this.prescribedBy,
    this.isRecurrent = false,
    this.recurrenceIntervalDays,
  });

  @override
  List<Object?> get props => [
        refillId,
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
        contactStatus,
        refillStatus,
        escalatedStatus,
        lastActionAt,
        prescribedBy,
        isRecurrent,
        recurrenceIntervalDays,
      ];
}
