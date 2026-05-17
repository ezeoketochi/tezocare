import 'package:equatable/equatable.dart';

class ChiefComplaintItem extends Equatable {
  final String? complaint;
  final String? duration;

  const ChiefComplaintItem({this.complaint, this.duration});

  @override
  List<Object?> get props => [complaint, duration];
}

class MedicationHistoryData extends Equatable {
  final List<String> pastMedications;
  final List<String> currentMedications;
  final String? adherence;
  final String? nonAdherenceReason;

  const MedicationHistoryData({
    this.pastMedications = const [],
    this.currentMedications = const [],
    this.adherence,
    this.nonAdherenceReason,
  });

  @override
  List<Object?> get props =>
      [pastMedications, currentMedications, adherence, nonAdherenceReason];
}

class VitalsData extends Equatable {
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final double? temperature;
  final int? spo2;
  final int? respiratoryRate;
  final double? weight;
  final double? height;
  final double? bmi;
  final double? glucose;
  final String? glucoseType;

  const VitalsData({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperature,
    this.spo2,
    this.respiratoryRate,
    this.weight,
    this.height,
    this.bmi,
    this.glucose,
    this.glucoseType,
  });

  @override
  List<Object?> get props => [
        bloodPressureSystolic,
        bloodPressureDiastolic,
        heartRate,
        temperature,
        spo2,
        respiratoryRate,
        weight,
        height,
        bmi,
        glucose,
        glucoseType,
      ];
}

class TestResultItem extends Equatable {
  final String? testName;
  final String? result;

  const TestResultItem({this.testName, this.result});

  @override
  List<Object?> get props => [testName, result];
}

class ClinicalAssessmentData extends Equatable {
  final String? diagnosis;
  final String? severity;
  final String? pharmacistNotes;

  const ClinicalAssessmentData({this.diagnosis, this.severity, this.pharmacistNotes});

  @override
  List<Object?> get props => [diagnosis, severity, pharmacistNotes];
}

class MedicationDispensedData extends Equatable {
  final String? drugName;
  final String? dose;
  final String? frequency;
  final String? duration;
  final DateTime? dateDispensed;
  final DateTime? refillDate;
  final String? specialInstructions;

  const MedicationDispensedData({
    this.drugName,
    this.dose,
    this.frequency,
    this.duration,
    this.dateDispensed,
    this.refillDate,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        drugName,
        dose,
        frequency,
        duration,
        dateDispensed,
        refillDate,
        specialInstructions,
      ];
}

class FollowUpData extends Equatable {
  final bool required;
  final DateTime? scheduledDate;
  final bool isDone;
  final String? outcome;

  const FollowUpData({
    this.required = false,
    this.scheduledDate,
    this.isDone = false,
    this.outcome,
  });

  @override
  List<Object?> get props => [required, scheduledDate, isDone, outcome];
}

class ReferralData extends Equatable {
  final bool isReferred;
  final String? destination;
  final String? reason;

  const ReferralData({
    this.isReferred = false,
    this.destination,
    this.reason,
  });

  @override
  List<Object?> get props => [isReferred, destination, reason];
}

class Visit extends Equatable {
  final String id;
  final String patientId;
  final String? patientName;
  final String staffId;
  final String? staffName;
  final String visitNumber;
  final DateTime visitDate;
  final String status;
  final List<ChiefComplaintItem> chiefComplaints;
  final MedicationHistoryData? medicationHistory;
  final VitalsData? vitals;
  final List<TestResultItem> testResults;
  final ClinicalAssessmentData? clinicalAssessment;
  final List<MedicationDispensedData> medicationsDispensed;
  final String? counsellingAdvice;
  final FollowUpData? followUp;
  final ReferralData? referral;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Visit({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.staffId,
    this.staffName,
    this.visitNumber = '',
    required this.visitDate,
    required this.status,
    this.chiefComplaints = const [],
    this.medicationHistory,
    this.vitals,
    this.testResults = const [],
    this.clinicalAssessment,
    this.medicationsDispensed = const [],
    this.counsellingAdvice,
    this.followUp,
    this.referral,
    this.createdAt,
    this.updatedAt,
  });

  String? get reason {
    if (chiefComplaints.isEmpty) return null;
    return chiefComplaints
        .where((c) => c.complaint != null && c.complaint!.isNotEmpty)
        .map((c) => '${c.complaint} (${c.duration ?? "N/A"})')
        .join('; ');
  }

  String? get diagnosis => clinicalAssessment?.diagnosis;

  String? get treatment {
    final parts = <String>[];
    if (medicationsDispensed.isNotEmpty) {
      final meds = medicationsDispensed
          .where((m) => m.drugName != null && m.drugName!.isNotEmpty)
          .map((m) =>
              '${m.drugName} ${m.dose ?? ""} ${m.frequency ?? ""}')
          .join('; ');
      if (meds.isNotEmpty) parts.add('Dispensed: $meds');
    }
    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  String? get notes {
    final parts = <String>[];
    if (counsellingAdvice != null && counsellingAdvice!.isNotEmpty) {
      parts.add('Counselling: $counsellingAdvice');
    }
    if (followUp != null && followUp!.required) {
      parts.add(
          'Follow-up: ${followUp!.scheduledDate?.toIso8601String().split('T')[0] ?? "TBD"}');
    }
    if (referral != null &&
        referral!.destination != null &&
        referral!.destination!.isNotEmpty) {
      parts.add(
          'Referral: ${referral!.destination} - ${referral!.reason ?? ""}');
    }
    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        staffId,
        staffName,
        visitNumber,
        visitDate,
        status,
        chiefComplaints,
        medicationHistory,
        vitals,
        testResults,
        clinicalAssessment,
        medicationsDispensed,
        counsellingAdvice,
        followUp,
        referral,
        createdAt,
        updatedAt,
      ];
}
