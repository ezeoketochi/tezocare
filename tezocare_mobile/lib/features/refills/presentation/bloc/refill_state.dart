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

class ContactRefillLoading extends RefillState {
  const ContactRefillLoading();
}

// class RefillLoaded extends RefillState {
//   final List<DueRefill> refills;
//   final int total;
//   final int overdue;
//   final int dueToday;
//   final int outreach;
//   final String? activeFilter;
//   final int? activeDays;

//   const RefillLoaded({
//     required this.refills,
//     this.total = 0,
//     this.overdue = 0,
//     this.dueToday = 0,
//     this.outreach = 0,
//     this.activeFilter,
//     this.activeDays,
//   });

//   @override
//   List<Object?> get props =>
//       [refills, total, overdue, dueToday, outreach, activeFilter, activeDays];
// }

class RefillError extends RefillState {
  final String message;

  const RefillError({required this.message});

  @override
  List<Object> get props => [message];
}

class RefillBatchCreated extends RefillState {
  final List<String> refillIds;

  const RefillBatchCreated({required this.refillIds});

  @override
  List<Object> get props => [refillIds];
}

class RefillLoaded extends RefillState {
  final List<DueRefill> refills;
  final int total;
  final int overdue;
  final int dueToday;
  final int outreach;
  final String? activeFilter;
  final int? activeDays;

  const RefillLoaded({
    required this.refills,
    this.total = 0,
    this.overdue = 0,
    this.dueToday = 0,
    this.outreach = 0,
    this.activeFilter,
    this.activeDays,
  });

  // Added copyWith for state preservation during single-item mutations
  RefillLoaded copyWith({
    List<DueRefill>? refills,
    int? total,
    int? overdue,
    int? dueToday,
    int? outreach,
    String? activeFilter,
    int? activeDays,
  }) {
    return RefillLoaded(
      refills: refills ?? this.refills,
      total: total ?? this.total,
      overdue: overdue ?? this.overdue,
      dueToday: dueToday ?? this.dueToday,
      outreach: outreach ?? this.outreach,
      activeFilter: activeFilter ?? this.activeFilter,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  @override
  List<Object?> get props => [
    refills,
    total,
    overdue,
    dueToday,
    outreach,
    activeFilter,
    activeDays,
  ];
}
