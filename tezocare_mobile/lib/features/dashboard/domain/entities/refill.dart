import 'package:equatable/equatable.dart';

class Refill extends Equatable {
  final String id;
  final String medicationId;
  final String medicationName;
  final String patientId;
  final String patientName;
  final DateTime? lastRefillDate;
  final DateTime? nextRefillDate;
  final bool isOverdue;

  const Refill({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.patientId,
    required this.patientName,
    this.lastRefillDate,
    this.nextRefillDate,
    required this.isOverdue,
  });

  @override
  List<Object?> get props => [
        id,
        medicationId,
        medicationName,
        patientId,
        patientName,
        lastRefillDate,
        nextRefillDate,
        isOverdue,
      ];
}
