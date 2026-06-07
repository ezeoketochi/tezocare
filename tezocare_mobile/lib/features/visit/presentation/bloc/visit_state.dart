import 'package:equatable/equatable.dart';
import '../../domain/entities/visit.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {
  const VisitInitial();
}

class VisitLoading extends VisitState {
  const VisitLoading();
}

class VisitsLoaded extends VisitState {
  final List<Visit> visits;
  final String? errorMessage;

  const VisitsLoaded({required this.visits, this.errorMessage});

  VisitsLoaded copyWith({
    List<Visit>? visits,
    String? errorMessage,
  }) {
    return VisitsLoaded(
      visits: visits ?? this.visits,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [visits, errorMessage];
}

class VisitDetailLoaded extends VisitState {
  final Visit visit;

  const VisitDetailLoaded({required this.visit});

  @override
  List<Object> get props => [visit];
}

class VisitCreated extends VisitState {
  final Visit visit;

  const VisitCreated({required this.visit});

  @override
  List<Object> get props => [visit];
}

class VisitDeleted extends VisitState {
  final String visitId;

  const VisitDeleted({required this.visitId});

  @override
  List<Object> get props => [visitId];
}

class VisitError extends VisitState {
  final String message;

  const VisitError({required this.message});

  @override
  List<Object> get props => [message];
}
