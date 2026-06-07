import 'package:dio/dio.dart';
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
  final CancelToken? cancelToken;

  const GetPatientsEvent({this.page = 1, this.search, this.status, this.cancelToken});

  @override
  List<Object?> get props => [page, search ?? '', status ?? '', cancelToken];
}

class GetPatientDetailEvent extends PatientEvent {
  final String id;
  final CancelToken? cancelToken;

  const GetPatientDetailEvent({required this.id, this.cancelToken});

  @override
  List<Object?> get props => [id, cancelToken];
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
  final CancelToken? cancelToken;

  const SearchPatientsEvent({required this.query, this.cancelToken});

  @override
  List<Object?> get props => [query, cancelToken];
}

class ClearPatientError extends PatientEvent {
  const ClearPatientError();
}
