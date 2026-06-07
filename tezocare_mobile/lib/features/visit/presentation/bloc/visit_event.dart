import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visit.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class CreateVisitEvent extends VisitEvent {
  final Visit visit;

  const CreateVisitEvent({required this.visit});

  @override
  List<Object?> get props => [visit];
}

class GetPatientVisitsEvent extends VisitEvent {
  final String patientId;
  final CancelToken? cancelToken;

  const GetPatientVisitsEvent({
    required this.patientId,
    this.cancelToken,
  });

  @override
  List<Object> get props => [patientId];
}

class GetVisitDetailEvent extends VisitEvent {
  final String id;
  final CancelToken? cancelToken;

  const GetVisitDetailEvent({
    required this.id,
    this.cancelToken,
  });

  @override
  List<Object> get props => [id];
}

class DeleteVisitEvent extends VisitEvent {
  final String id;

  const DeleteVisitEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class ClearVisitError extends VisitEvent {
  const ClearVisitError();
}
