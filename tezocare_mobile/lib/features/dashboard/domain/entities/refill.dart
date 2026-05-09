import 'package:equatable/equatable.dart';

class Refill extends Equatable {
  final int id;
  final int medicationId;
  final String medicationName;
  final int patientId;
  final String patientName;
  final DateTime lastRefillDate;
  final DateTime nextRefillDate;
  final bool isOverdue;

  const Refill({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.patientId,
    required this.patientName,
    required this.lastRefillDate,
    required this.nextRefillDate,
    required this.isOverdue,
  });

  @override
  List<Object> get props => [
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
