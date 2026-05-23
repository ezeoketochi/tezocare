import 'package:equatable/equatable.dart';
import '../../domain/entities/due_refill.dart';

abstract class RefillState extends Equatable {
  const RefillState();

  @override
  List<Object?> get props => [];
}

class RefillInitial extends RefillState {
  const RefillInitial();
}

class RefillLoading extends RefillState {
  const RefillLoading();
}

class RefillLoaded extends RefillState {
  final List<DueRefill> refills;
  final int total;
  final int overdue;
  final int dueToday;
  final int upcoming;

  const RefillLoaded({
    required this.refills,
    this.total = 0,
    this.overdue = 0,
    this.dueToday = 0,
    this.upcoming = 0,
  });

  @override
  List<Object> get props => [refills, total, overdue, dueToday, upcoming];
}

class RefillError extends RefillState {
  final String message;

  const RefillError({required this.message});

  @override
  List<Object> get props => [message];
}
