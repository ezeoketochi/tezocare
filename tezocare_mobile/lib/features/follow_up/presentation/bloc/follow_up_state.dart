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
  final String? errorMessage;
  final String? successMessage;
  final bool isBackgroundUpdating;
  final String? backgroundError;

  const FollowUpLoaded({
    required this.followUps,
    this.total = 0,
    this.overdue = 0,
    this.dueToday = 0,
    this.upcoming = 0,
    this.errorMessage,
    this.successMessage,
    this.isBackgroundUpdating = false,
    this.backgroundError,
  });

  FollowUpLoaded copyWith({
    List<DueFollowUp>? followUps,
    int? total,
    int? overdue,
    int? dueToday,
    int? upcoming,
    String? errorMessage,
    String? successMessage,
    bool? isBackgroundUpdating,
    String? backgroundError,
  }) {
    return FollowUpLoaded(
      followUps: followUps ?? this.followUps,
      total: total ?? this.total,
      overdue: overdue ?? this.overdue,
      dueToday: dueToday ?? this.dueToday,
      upcoming: upcoming ?? this.upcoming,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isBackgroundUpdating: isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
    );
  }

  @override
  List<Object?> get props => [
    followUps, total, overdue, dueToday, upcoming,
    errorMessage, successMessage, isBackgroundUpdating, backgroundError,
  ];
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
