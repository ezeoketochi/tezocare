import '../../domain/entities/visit.dart';

class ChiefComplaintItemModel extends ChiefComplaintItem {
  const ChiefComplaintItemModel({super.complaint, super.duration});

  factory ChiefComplaintItemModel.fromJson(Map<String, dynamic> json) {
    return ChiefComplaintItemModel(
      complaint: json['complaint'] as String?,
      duration: json['duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (complaint != null) 'complaint': complaint,
      if (duration != null) 'duration': duration,
    };
  }
}

class MedicationHistoryDataModel extends MedicationHistoryData {
  const MedicationHistoryDataModel({
    super.pastMedications,
    super.currentMedications,
    super.adherence,
    super.nonAdherenceReason,
  });

  factory MedicationHistoryDataModel.fromJson(Map<String, dynamic> json) {
    return MedicationHistoryDataModel(
      pastMedications: json['past_medications'] != null
          ? List<String>.from(json['past_medications'] as List)
          : const [],
      currentMedications: json['current_medications'] != null
          ? List<String>.from(json['current_medications'] as List)
          : const [],
      adherence: json['adherence'] as String?,
      nonAdherenceReason: json['non_adherence_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pastMedications.isNotEmpty) 'past_medications': pastMedications,
      if (currentMedications.isNotEmpty)
        'current_medications': currentMedications,
      if (adherence != null) 'adherence': adherence,
      if (nonAdherenceReason != null)
        'non_adherence_reason': nonAdherenceReason,
    };
  }
}

class VitalsDataModel extends VitalsData {
  const VitalsDataModel({
    super.bloodPressureSystolic,
    super.bloodPressureDiastolic,
    super.heartRate,
    super.temperature,
    super.spo2,
    super.respiratoryRate,
    super.weight,
    super.height,
    super.bmi,
    super.glucose,
    super.glucoseType,
  });

  factory VitalsDataModel.fromJson(Map<String, dynamic> json) {
    return VitalsDataModel(
      bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
      bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
      heartRate: json['heart_rate'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      spo2: json['spo2'] as int?,
      respiratoryRate: json['respiratory_rate'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      glucose: (json['glucose'] as num?)?.toDouble(),
      glucoseType: json['glucose_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bloodPressureSystolic != null)
        'blood_pressure_systolic': bloodPressureSystolic,
      if (bloodPressureDiastolic != null)
        'blood_pressure_diastolic': bloodPressureDiastolic,
      if (heartRate != null) 'heart_rate': heartRate,
      if (temperature != null) 'temperature': temperature,
      if (spo2 != null) 'spo2': spo2,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bmi != null) 'bmi': bmi,
      if (glucose != null) 'glucose': glucose,
      if (glucoseType != null) 'glucose_type': glucoseType,
    };
  }
}

class TestResultItemModel extends TestResultItem {
  const TestResultItemModel({super.testName, super.result});

  factory TestResultItemModel.fromJson(Map<String, dynamic> json) {
    return TestResultItemModel(
      testName: json['test_name'] as String?,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (testName != null) 'test_name': testName,
      if (result != null) 'result': result,
    };
  }
}

class ClinicalAssessmentDataModel extends ClinicalAssessmentData {
  const ClinicalAssessmentDataModel({
    super.diagnosis,
    super.severity,
    super.pharmacistNotes,
  });

  factory ClinicalAssessmentDataModel.fromJson(Map<String, dynamic> json) {
    return ClinicalAssessmentDataModel(
      diagnosis: json['diagnosis'] as String?,
      severity: json['severity'] as String?,
      pharmacistNotes: json['pharmacist_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (severity != null) 'severity': severity,
      if (pharmacistNotes != null) 'pharmacist_notes': pharmacistNotes,
    };
  }
}

class MedicationDispensedDataModel extends MedicationDispensedData {
  const MedicationDispensedDataModel({
    super.drugName,
    super.dose,
    super.frequency,
    super.duration,
    super.dateDispensed,
    super.refillDate,
    super.specialInstructions,
  });

  factory MedicationDispensedDataModel.fromJson(Map<String, dynamic> json) {
    return MedicationDispensedDataModel(
      drugName: json['drug_name'] as String?,
      dose: json['dose'] as String?,
      frequency: json['frequency'] as String?,
      duration: json['duration'] as String?,
      dateDispensed: json['date_dispensed'] != null
          ? DateTime.parse(json['date_dispensed'] as String)
          : null,
      refillDate: json['refill_date'] != null
          ? DateTime.parse(json['refill_date'] as String)
          : null,
      specialInstructions: json['special_instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (drugName != null) 'drug_name': drugName,
      if (dose != null) 'dose': dose,
      if (frequency != null) 'frequency': frequency,
      if (duration != null) 'duration': duration,
      if (dateDispensed != null)
        'date_dispensed': dateDispensed!.toIso8601String().split('T')[0],
      if (refillDate != null)
        'refill_date': refillDate!.toIso8601String().split('T')[0],
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
    };
  }
}

class FollowUpDataModel extends FollowUpData {
  const FollowUpDataModel({super.required, super.date});

  factory FollowUpDataModel.fromJson(Map<String, dynamic> json) {
    return FollowUpDataModel(
      required: json['required'] as bool? ?? false,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required': required,
      if (date != null) 'date': date!.toIso8601String().split('T')[0],
    };
  }
}

class ReferralDataModel extends ReferralData {
  const ReferralDataModel({super.destination, super.reason});

  factory ReferralDataModel.fromJson(Map<String, dynamic> json) {
    return ReferralDataModel(
      destination: json['destination'] as String?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (destination != null) 'destination': destination,
      if (reason != null) 'reason': reason,
    };
  }
}

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.staffId,
    super.staffName,
    super.visitNumber,
    required super.visitDate,
    required super.status,
    super.chiefComplaints,
    super.medicationHistory,
    super.vitals,
    super.testResults,
    super.clinicalAssessment,
    super.medicationsDispensed,
    super.counsellingAdvice,
    super.followUp,
    super.referral,
    super.createdAt,
    super.updatedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as int,
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      staffId: json['staff_id'] as int? ?? 0,
      staffName: json['staff_name'] as String?,
      visitNumber: json['visit_number'] as String? ?? '',
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'active',
      chiefComplaints: json['chief_complaints'] != null
          ? (json['chief_complaints'] as List<dynamic>)
              .map((e) =>
                  ChiefComplaintItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      medicationHistory: json['medication_history'] != null
          ? MedicationHistoryDataModel.fromJson(
              json['medication_history'] as Map<String, dynamic>)
          : null,
      vitals: json['vitals'] != null
          ? VitalsDataModel.fromJson(json['vitals'] as Map<String, dynamic>)
          : null,
      testResults: json['test_results'] != null
          ? (json['test_results'] as List<dynamic>)
              .map((e) =>
                  TestResultItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      clinicalAssessment: json['clinical_assessment'] != null
          ? ClinicalAssessmentDataModel.fromJson(
              json['clinical_assessment'] as Map<String, dynamic>)
          : null,
      medicationsDispensed: json['medications_dispensed'] != null
          ? (json['medications_dispensed'] as List<dynamic>)
              .map((e) => MedicationDispensedDataModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : const [],
      counsellingAdvice: json['counselling_advice'] as String?,
      followUp: json['follow_up'] != null
          ? FollowUpDataModel.fromJson(
              json['follow_up'] as Map<String, dynamic>)
          : null,
      referral: json['referral'] != null
          ? ReferralDataModel.fromJson(
              json['referral'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'staff_id': staffId,
      'visit_number': visitNumber,
      'visit_date': visitDate.toIso8601String().split('T')[0],
      'status': status,
      if (chiefComplaints.isNotEmpty)
        'chief_complaints':
            chiefComplaints.map((e) => (e as ChiefComplaintItemModel).toJson()).toList(),
      if (medicationHistory != null)
        'medication_history':
            (medicationHistory as MedicationHistoryDataModel).toJson(),
      if (vitals != null) 'vitals': (vitals as VitalsDataModel).toJson(),
      if (testResults.isNotEmpty)
        'test_results':
            testResults.map((e) => (e as TestResultItemModel).toJson()).toList(),
      if (clinicalAssessment != null)
        'clinical_assessment':
            (clinicalAssessment as ClinicalAssessmentDataModel).toJson(),
      if (medicationsDispensed.isNotEmpty)
        'medications_dispensed': medicationsDispensed
            .map((e) => (e as MedicationDispensedDataModel).toJson())
            .toList(),
      if (counsellingAdvice != null) 'counselling_advice': counsellingAdvice,
      if (followUp != null) 'follow_up': (followUp as FollowUpDataModel).toJson(),
      if (referral != null) 'referral': (referral as ReferralDataModel).toJson(),
    };
  }
}
