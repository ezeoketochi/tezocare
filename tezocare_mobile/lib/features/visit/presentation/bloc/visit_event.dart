import 'package:equatable/equatable.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/vitals.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class CreateVisitEvent extends VisitEvent {
  final Visit visit;
  final Vitals? vitals;

  const CreateVisitEvent({required this.visit, this.vitals});

  @override
  List<Object?> get props => [visit, vitals];
}

class GetPatientVisitsEvent extends VisitEvent {
  final int patientId;

  const GetPatientVisitsEvent({required this.patientId});

  @override
  List<Object> get props => [patientId];
}

class GetVisitDetailEvent extends VisitEvent {
  final int id;

  const GetVisitDetailEvent({required this.id});

  @override
  List<Object> get props => [id];
}
