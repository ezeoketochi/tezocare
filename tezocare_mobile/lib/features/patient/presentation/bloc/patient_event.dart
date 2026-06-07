import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class GetPatientsEvent extends PatientEvent {
  final int page;
  final String? search;
  final String? status;

  const GetPatientsEvent({this.page = 1, this.search, this.status});

  @override
  List<Object> get props => [page, search ?? '', status ?? ''];
}

class GetPatientDetailEvent extends PatientEvent {
  final String id;

  const GetPatientDetailEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class CreatePatientEvent extends PatientEvent {
  final Patient patient;

  const CreatePatientEvent({required this.patient});

  @override
  List<Object> get props => [patient];
}

class UpdatePatientEvent extends PatientEvent {
  final Patient patient;

  const UpdatePatientEvent({required this.patient});

  @override
  List<Object> get props => [patient];
}

class SearchPatientsEvent extends PatientEvent {
  final String query;

  const SearchPatientsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearPatientError extends PatientEvent {
  const ClearPatientError();
}
