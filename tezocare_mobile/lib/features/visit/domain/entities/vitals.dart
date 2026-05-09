import 'package:equatable/equatable.dart';

class Vitals extends Equatable {
  final int? id;
  final int? visitId;
  final double? temperature;
  final int? heartRate;
  final int? respiratoryRate;
  final double? weight;
  final String? mucousMembranes;
  final int? capillaryRefillTime;
  final String? hydrationStatus;
  final String? otherFindings;
  final DateTime? recordedAt;

  const Vitals({
    this.id,
    this.visitId,
    this.temperature,
    this.heartRate,
    this.respiratoryRate,
    this.weight,
    this.mucousMembranes,
    this.capillaryRefillTime,
    this.hydrationStatus,
    this.otherFindings,
    this.recordedAt,
  });

  @override
  List<Object?> get props => [
        id,
        visitId,
        temperature,
        heartRate,
        respiratoryRate,
        weight,
        mucousMembranes,
        capillaryRefillTime,
        hydrationStatus,
        otherFindings,
        recordedAt,
      ];
}
