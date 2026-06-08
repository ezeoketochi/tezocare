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
  final bool isBackgroundUpdating;
  final String? backgroundError;
  final String? errorMessage;

  const VisitsLoaded({
    required this.visits,
    this.isBackgroundUpdating = false,
    this.backgroundError,
    this.errorMessage,
  });

  VisitsLoaded copyWith({
    List<Visit>? visits,
    bool? isBackgroundUpdating,
    String? backgroundError,
    String? errorMessage,
  }) {
    return VisitsLoaded(
      visits: visits ?? this.visits,
      isBackgroundUpdating:
          isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [visits, isBackgroundUpdating, backgroundError, errorMessage];
}

class VisitDetailLoaded extends VisitState {
  final Visit visit;
  final bool isBackgroundUpdating;
  final String? backgroundError;

  const VisitDetailLoaded({
    required this.visit,
    this.isBackgroundUpdating = false,
    this.backgroundError,
  });

  VisitDetailLoaded copyWith({
    Visit? visit,
    bool? isBackgroundUpdating,
    String? backgroundError,
  }) {
    return VisitDetailLoaded(
      visit: visit ?? this.visit,
      isBackgroundUpdating:
          isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
    );
  }

  @override
  List<Object?> get props =>
      [visit, isBackgroundUpdating, backgroundError];
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

class VisitDeleteSuccess extends VisitState {
  const VisitDeleteSuccess();

  @override
  List<Object> get props => [];
}

class VisitError extends VisitState {
  final String message;

  const VisitError({required this.message});

  @override
  List<Object> get props => [message];
}
