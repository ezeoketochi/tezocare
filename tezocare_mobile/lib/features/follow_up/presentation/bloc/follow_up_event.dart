import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class FollowUpEvent extends Equatable {
  const FollowUpEvent();

  @override
  List<Object?> get props => [];
}

class GetDueFollowUpsEvent extends FollowUpEvent {
  final String? filter;
  final int? days;
  final CancelToken? cancelToken;

  const GetDueFollowUpsEvent({this.filter, this.days, this.cancelToken});

  @override
  List<Object?> get props => [filter, days, cancelToken];
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
