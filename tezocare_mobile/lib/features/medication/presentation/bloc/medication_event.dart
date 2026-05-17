import 'package:equatable/equatable.dart';
import '../../domain/entities/medication.dart';

abstract class MedicationEvent extends Equatable {
  const MedicationEvent();

  @override
  List<Object?> get props => [];
}

class AddMedicationEvent extends MedicationEvent {
  final Medication medication;

  const AddMedicationEvent({required this.medication});

  @override
  List<Object> get props => [medication];
}

class GetPatientMedicationsEvent extends MedicationEvent {
  final String patientId;

  const GetPatientMedicationsEvent({required this.patientId});

  @override
  List<Object> get props => [patientId];
}

class UpdateMedicationEvent extends MedicationEvent {
  final Medication medication;

  const UpdateMedicationEvent({required this.medication});

  @override
  List<Object> get props => [medication];
}

class DeactivateMedicationEvent extends MedicationEvent {
  final String id;

  const DeactivateMedicationEvent({required this.id});

  @override
  List<Object> get props => [id];
}
