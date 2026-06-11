import 'package:equatable/equatable.dart';
import 'package:tezocare_mobile/features/follow_up/domain/entities/due_follow_up.dart';

// 1. Use an enum to manage action & initialization lifecycles cleanly
enum FollowUpStatus { initial, loading, loaded, error }

enum ActionStatus { idle, loading, success, failure }

abstract class FollowUpState extends Equatable {
  const FollowUpState();

  @override
  List<Object?> get props => [];
}

class FollowUpStateContainer extends FollowUpState {
  final List<DueFollowUp> followUps;
  final int total;
  final int overdue;
  final int dueToday;
  final int upcoming;

  // Status controls
  final FollowUpStatus status;
  final ActionStatus actionStatus; // For marking done, editing, deleting, etc.

  // Informational strings
  final String? errorMessage;
  final String? successMessage;

  const FollowUpStateContainer({
    this.followUps = const [],
    this.total = 0,
    this.overdue = 0,
    this.dueToday = 0,
    this.upcoming = 0,
    this.status = FollowUpStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  // Factory constructors keep your BLoC files readable and expressive
  factory FollowUpStateContainer.initial() => const FollowUpStateContainer();

  factory FollowUpStateContainer.loading() =>
      const FollowUpStateContainer(status: FollowUpStatus.loading);

  FollowUpStateContainer copyWith({
    List<DueFollowUp>? followUps,
    int? total,
    int? overdue,
    int? dueToday,
    int? upcoming,
    FollowUpStatus? status,
    ActionStatus? actionStatus,
    // Allows explicitly clearing out string notifications by passing null
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return FollowUpStateContainer(
      followUps: followUps ?? this.followUps,
      total: total ?? this.total,
      overdue: overdue ?? this.overdue,
      dueToday: dueToday ?? this.dueToday,
      upcoming: upcoming ?? this.upcoming,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null
          ? successMessage()
          : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    followUps,
    total,
    overdue,
    dueToday,
    upcoming,
    status,
    actionStatus,
    errorMessage,
    successMessage,
  ];
}
