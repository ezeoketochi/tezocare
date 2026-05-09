import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {
  const PatientInitial();
}

class PatientLoading extends PatientState {
  const PatientLoading();
}

class PatientsLoaded extends PatientState {
  final List<Patient> patients;
  final int currentPage;
  final bool hasMorePages;

  const PatientsLoaded({
    required this.patients,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  @override
  List<Object> get props => [patients, currentPage, hasMorePages];
}

class PatientDetailLoaded extends PatientState {
  final Patient patient;

  const PatientDetailLoaded({required this.patient});

  @override
  List<Object> get props => [patient];
}

class PatientCreated extends PatientState {
  final Patient patient;

  const PatientCreated({required this.patient});

  @override
  List<Object> get props => [patient];
}

class PatientUpdated extends PatientState {
  final Patient patient;

  const PatientUpdated({required this.patient});

  @override
  List<Object> get props => [patient];
}

class PatientError extends PatientState {
  final String message;

  const PatientError({required this.message});

  @override
  List<Object> get props => [message];
}
