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

  const GetPatientVisitsEvent({required this.patientId});

  @override
  List<Object> get props => [patientId];
}

class GetVisitDetailEvent extends VisitEvent {
  final String id;

  const GetVisitDetailEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteVisitEvent extends VisitEvent {
  final String id;

  const DeleteVisitEvent({required this.id});

  @override
  List<Object> get props => [id];
}
