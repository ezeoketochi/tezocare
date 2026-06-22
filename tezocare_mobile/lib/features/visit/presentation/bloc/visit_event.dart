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

class UpdateVisitEvent extends VisitEvent {
  final String id;
  final Visit visit;

  const UpdateVisitEvent({required this.id, required this.visit});

  @override
  List<Object?> get props => [id, visit];
}

class DeleteVisitEvent extends VisitEvent {
  final String id;
  final String patientId;

  const DeleteVisitEvent({required this.id, required this.patientId});

  @override
  List<Object> get props => [id, patientId];
}

class ClearVisitError extends VisitEvent {
  const ClearVisitError();
}
