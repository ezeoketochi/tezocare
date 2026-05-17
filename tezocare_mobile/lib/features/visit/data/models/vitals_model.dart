import '../../domain/entities/vitals.dart';

class VitalsModel extends Vitals {
  const VitalsModel({
    super.id,
    super.visitId,
    super.temperature,
    super.heartRate,
    super.respiratoryRate,
    super.weight,
    super.mucousMembranes,
    super.capillaryRefillTime,
    super.hydrationStatus,
    super.otherFindings,
    super.recordedAt,
  });

  factory VitalsModel.fromJson(Map<String, dynamic> json) {
    return VitalsModel(
      id: json['id'] as String?,
      visitId: json['visit_id'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      heartRate: json['heart_rate'] as int?,
      respiratoryRate: json['respiratory_rate'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      mucousMembranes: json['mucous_membranes'] as String?,
      capillaryRefillTime: json['capillary_refill_time'] as int?,
      hydrationStatus: json['hydration_status'] as String?,
      otherFindings: json['other_findings'] as String?,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit_id': visitId,
      'temperature': temperature,
      'heart_rate': heartRate,
      'respiratory_rate': respiratoryRate,
      'weight': weight,
      'mucous_membranes': mucousMembranes,
      'capillary_refill_time': capillaryRefillTime,
      'hydration_status': hydrationStatus,
      'other_findings': otherFindings,
      'recorded_at': recordedAt?.toIso8601String(),
    };
  }
}
