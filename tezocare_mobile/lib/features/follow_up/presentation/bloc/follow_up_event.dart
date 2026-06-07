import 'package:equatable/equatable.dart';

abstract class FollowUpEvent extends Equatable {
  const FollowUpEvent();

  @override
  List<Object?> get props => [];
}

class GetDueFollowUpsEvent extends FollowUpEvent {
  final int? days;

  const GetDueFollowUpsEvent({this.days});

  @override
  List<Object?> get props => [days];
}

class MarkFollowUpDoneEvent extends FollowUpEvent {
  final String visitId;
  final String outcome;

  const MarkFollowUpDoneEvent({required this.visitId, required this.outcome});

  @override
  List<Object> get props => [visitId, outcome];
}

class ClearFollowUpError extends FollowUpEvent {
  const ClearFollowUpError();
}
