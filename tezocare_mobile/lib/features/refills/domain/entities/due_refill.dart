import 'package:equatable/equatable.dart';

class DueRefill extends Equatable {
  final String refillId;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String visitId;
  final DateTime? visitDate;
  final String drugName;
  final double? doseAmount;
  final String? doseUnit;
  final String? route;
  final String frequency;
  final String? frequencyCode;
  final int? durationAmount;
  final String? durationUnit;
  final int? totalQuantity;
  final String? instructions;
  final String? sigString;
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
    this.doseAmount,
    this.doseUnit,
    this.route,
    this.frequency = '',
    this.frequencyCode,
    this.durationAmount,
    this.durationUnit,
    this.totalQuantity,
    this.instructions,
    this.sigString,
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

  // ADDED: copyWith method for immutable state updates
  DueRefill copyWith({
    String? refillId,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? visitId,
    DateTime? visitDate,
    String? drugName,
    double? doseAmount,
    String? doseUnit,
    String? route,
    String? frequency,
    String? frequencyCode,
    int? durationAmount,
    String? durationUnit,
    int? totalQuantity,
    String? instructions,
    String? sigString,
    String? dateDispensed,
    String? refillDate,
    int? daysUntilRefill,
    String? contactStatus,
    String? refillStatus,
    String? escalatedStatus,
    DateTime? lastActionAt,
    String? prescribedBy,
    bool? isRecurrent,
    int? recurrenceIntervalDays,
  }) {
    return DueRefill(
      refillId: refillId ?? this.refillId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      visitId: visitId ?? this.visitId,
      visitDate: visitDate ?? this.visitDate,
      drugName: drugName ?? this.drugName,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      frequencyCode: frequencyCode ?? this.frequencyCode,
      durationAmount: durationAmount ?? this.durationAmount,
      durationUnit: durationUnit ?? this.durationUnit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      instructions: instructions ?? this.instructions,
      sigString: sigString ?? this.sigString,
      dateDispensed: dateDispensed ?? this.dateDispensed,
      refillDate: refillDate ?? this.refillDate,
      daysUntilRefill: daysUntilRefill ?? this.daysUntilRefill,
      contactStatus: contactStatus ?? this.contactStatus,
      refillStatus: refillStatus ?? this.refillStatus,
      escalatedStatus: escalatedStatus ?? this.escalatedStatus,
      lastActionAt: lastActionAt ?? this.lastActionAt,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      recurrenceIntervalDays:
          recurrenceIntervalDays ?? this.recurrenceIntervalDays,
    );
  }

  String get sig => sigString ?? _buildSigString();

  String _buildSigString() {
    final parts = <String>[];
    if (doseAmount != null) {
      final unit = doseUnit != null && doseUnit!.isNotEmpty
          ? '$doseUnit(s)'
          : '';
      parts.add('$doseAmount $unit'.trim());
    }
    if (route != null && route!.isNotEmpty) parts.add(route!);
    if (frequency.isNotEmpty) parts.add(frequency);
    if (durationAmount != null &&
        durationUnit != null &&
        durationUnit!.isNotEmpty) {
      parts.add('for $durationAmount $durationUnit');
    }
    if (instructions != null && instructions!.isNotEmpty) {
      parts.add('($instructions)');
    }
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [
    refillId,
    patientId,
    patientName,
    patientPhone,
    visitId,
    visitDate,
    drugName,
    doseAmount,
    doseUnit,
    route,
    frequency,
    frequencyCode,
    durationAmount,
    durationUnit,
    totalQuantity,
    instructions,
    sigString,
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
