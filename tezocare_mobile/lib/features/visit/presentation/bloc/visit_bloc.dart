import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_visit_usecase.dart';
import '../../domain/usecases/delete_visit_usecase.dart';
import '../../domain/usecases/get_patient_visits_usecase.dart';
import '../../domain/usecases/get_visit_detail_usecase.dart';
import 'visit_event.dart';
import 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final CreateVisitUseCase createVisitUseCase;
  final GetPatientVisitsUseCase getPatientVisitsUseCase;
  final GetVisitDetailUseCase getVisitDetailUseCase;
  final DeleteVisitUseCase deleteVisitUseCase;

  VisitBloc({
    required this.createVisitUseCase,
    required this.getPatientVisitsUseCase,
    required this.getVisitDetailUseCase,
    required this.deleteVisitUseCase,
  }) : super(const VisitInitial()) {
    on<CreateVisitEvent>(_onCreateVisit);
    on<GetPatientVisitsEvent>(_onGetPatientVisits);
    on<GetVisitDetailEvent>(_onGetVisitDetail);
    on<DeleteVisitEvent>(_onDeleteVisit);
    on<ClearVisitError>(_onClearVisitError);
  }

  Future<void> _onCreateVisit(
    CreateVisitEvent event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());
    final result = await createVisitUseCase(
      CreateVisitParams(visit: event.visit),
    );
    result.fold(
      (failure) => emit(VisitError(message: _failureMessage(failure))),
      (visit) => emit(VisitCreated(visit: visit)),
    );
  }

  Future<void> _onGetPatientVisits(
    GetPatientVisitsEvent event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());
    final result = await getPatientVisitsUseCase(
      GetPatientVisitsParams(patientId: event.patientId),
    );
    result.fold(
      (failure) => emit(VisitError(message: _failureMessage(failure))),
      (visits) => emit(VisitsLoaded(visits: visits)),
    );
  }

  Future<void> _onGetVisitDetail(
    GetVisitDetailEvent event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());
    final result = await getVisitDetailUseCase(
      GetVisitDetailParams(id: event.id),
    );
    result.fold(
      (failure) => emit(VisitError(message: _failureMessage(failure))),
      (visit) => emit(VisitDetailLoaded(visit: visit)),
    );
  }

  Future<void> _onDeleteVisit(
    DeleteVisitEvent event,
    Emitter<VisitState> emit,
  ) async {
    final current = state;
    if (current is! VisitsLoaded) return;
    final previousVisits = current.visits;
    final updatedVisits = current.visits.where((v) => v.id != event.id).toList();
    emit(current.copyWith(visits: updatedVisits));
    final result = await deleteVisitUseCase(
      DeleteVisitParams(id: event.id),
    );
    result.fold(
      (failure) => emit(current.copyWith(visits: previousVisits, errorMessage: _failureMessage(failure))),
      (_) => null,
    );
  }

  void _onClearVisitError(ClearVisitError event, Emitter<VisitState> emit) {
    final current = state;
    if (current is VisitsLoaded) {
      emit(current.copyWith(errorMessage: null));
    }
  }

  String _failureMessage(Failure failure) {
    if (failure is ValidationFailure && failure.errors.isNotEmpty) {
      return failure.errors.values.first.toString();
    }
    return failure.message.isNotEmpty
        ? failure.message
        : 'Something went wrong. Please try again.';
  }
}
