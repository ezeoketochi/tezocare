import 'package:equatable/equatable.dart';
import '../../domain/entities/due_follow_up.dart';

abstract class FollowUpState extends Equatable {
  const FollowUpState();

  @override
  List<Object?> get props => [];
}

class FollowUpInitial extends FollowUpState {
  const FollowUpInitial();
}

class FollowUpLoading extends FollowUpState {
  const FollowUpLoading();
}

class FollowUpLoaded extends FollowUpState {
  final List<DueFollowUp> followUps;
  final int total;
  final int overdue;
  final int dueToday;
  final int upcoming;

  const FollowUpLoaded({
    required this.followUps,
    this.total = 0,
    this.overdue = 0,
    this.dueToday = 0,
    this.upcoming = 0,
  });

  @override
  List<Object> get props => [followUps, total, overdue, dueToday, upcoming];
}

class FollowUpMarkedDone extends FollowUpState {
  final String visitId;
  final String patientId;

  const FollowUpMarkedDone({required this.visitId, required this.patientId});

  @override
  List<Object> get props => [visitId, patientId];
}

class FollowUpError extends FollowUpState {
  final String message;

  const FollowUpError({required this.message});

  @override
  List<Object> get props => [message];
}
