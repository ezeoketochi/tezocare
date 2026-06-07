import 'package:equatable/equatable.dart';
import '../../domain/entities/medication.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();

  @override
  List<Object?> get props => [];
}

class MedicationInitial extends MedicationState {
  const MedicationInitial();
}

class MedicationLoading extends MedicationState {
  const MedicationLoading();
}

class MedicationsLoaded extends MedicationState {
  final List<Medication> medications;
  final String? errorMessage;

  const MedicationsLoaded({required this.medications, this.errorMessage});

  MedicationsLoaded copyWith({
    List<Medication>? medications,
    String? errorMessage,
  }) {
    return MedicationsLoaded(
      medications: medications ?? this.medications,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [medications, errorMessage];
}

class MedicationAdded extends MedicationState {
  final Medication medication;

  const MedicationAdded({required this.medication});

  @override
  List<Object> get props => [medication];
}

class MedicationUpdated extends MedicationState {
  final Medication medication;

  const MedicationUpdated({required this.medication});

  @override
  List<Object> get props => [medication];
}

class MedicationDeactivated extends MedicationState {
  const MedicationDeactivated();
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError({required this.message});

  @override
  List<Object> get props => [message];
}
