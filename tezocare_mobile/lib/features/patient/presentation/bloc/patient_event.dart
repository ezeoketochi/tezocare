import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class GetPatientsEvent extends PatientEvent {
  final int page;

  const GetPatientsEvent({this.page = 1});

  @override
  List<Object> get props => [page];
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
