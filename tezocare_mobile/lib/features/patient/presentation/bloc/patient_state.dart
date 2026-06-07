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
  final String? errorMessage;
  final bool isBackgroundUpdating;
  final String? backgroundError;

  const PatientsLoaded({
    required this.patients,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.errorMessage,
    this.isBackgroundUpdating = false,
    this.backgroundError,
  });

  PatientsLoaded copyWith({
    List<Patient>? patients,
    int? currentPage,
    bool? hasMorePages,
    String? errorMessage,
    bool? isBackgroundUpdating,
    String? backgroundError,
  }) {
    return PatientsLoaded(
      patients: patients ?? this.patients,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      errorMessage: errorMessage,
      isBackgroundUpdating: isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
    );
  }

  @override
  List<Object?> get props => [
    patients, currentPage, hasMorePages, errorMessage,
    isBackgroundUpdating, backgroundError,
  ];
}

class PatientDetailLoaded extends PatientState {
  final Patient patient;
  final String? errorMessage;
  final bool isBackgroundUpdating;
  final String? backgroundError;

  const PatientDetailLoaded({
    required this.patient,
    this.errorMessage,
    this.isBackgroundUpdating = false,
    this.backgroundError,
  });

  PatientDetailLoaded copyWith({
    Patient? patient,
    String? errorMessage,
    bool? isBackgroundUpdating,
    String? backgroundError,
  }) {
    return PatientDetailLoaded(
      patient: patient ?? this.patient,
      errorMessage: errorMessage,
      isBackgroundUpdating: isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
    );
  }

  @override
  List<Object?> get props => [
    patient, errorMessage, isBackgroundUpdating, backgroundError,
  ];
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
