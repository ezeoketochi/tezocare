import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tezocare_mobile/features/visit/domain/repositories/visit_repository.dart';
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
  final VisitRepository visitRepository;

  CancelToken? _visitsCancelToken;
  CancelToken? _detailCancelToken;

  VisitBloc({
    required this.createVisitUseCase,
    required this.getPatientVisitsUseCase,
    required this.getVisitDetailUseCase,
    required this.deleteVisitUseCase,
    required this.visitRepository,
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
    _visitsCancelToken?.cancel();
    _visitsCancelToken = CancelToken();

    final current = state;

    if (current is VisitsLoaded) {
      emit(current.copyWith(isBackgroundUpdating: true, backgroundError: null));
    } else {
      final cachedVisits = await visitRepository.getLocalVisits(
        event.patientId,
      );
      if (cachedVisits.isNotEmpty) {
        emit(VisitsLoaded(visits: cachedVisits, isBackgroundUpdating: true));
      }
    }

    final result = await getPatientVisitsUseCase(
      GetPatientVisitsParams(
        patientId: event.patientId,
        cancelToken: _visitsCancelToken,
      ),
    );

    result.fold(
      (failure) {
        if (_visitsCancelToken?.isCancelled == true) return;

        if (state is VisitsLoaded) {
          emit(
            (state as VisitsLoaded).copyWith(
              isBackgroundUpdating: false,
              backgroundError: failure.message,
            ),
          );
        } else {
          emit(VisitError(message: failure.message));
        }
      },
      (freshVisits) {
        visitRepository.saveLocalVisits(event.patientId, freshVisits);
        emit(VisitsLoaded(visits: freshVisits, isBackgroundUpdating: false));
      },
    );
  }

  Future<void> _onGetVisitDetail(
    GetVisitDetailEvent event,
    Emitter<VisitState> emit,
  ) async {
    _detailCancelToken?.cancel();
    _detailCancelToken = CancelToken();

    final current = state;

    if (current is VisitDetailLoaded) {
      emit(current.copyWith(isBackgroundUpdating: true, backgroundError: null));
    } else {
      final cachedDetail = await visitRepository.getLocalVisitDetail(event.id);
      if (cachedDetail != null) {
        emit(
          VisitDetailLoaded(visit: cachedDetail, isBackgroundUpdating: true),
        );
      }
    }

    final result = await getVisitDetailUseCase(
      GetVisitDetailParams(id: event.id, cancelToken: _detailCancelToken),
    );

    result.fold(
      (failure) {
        if (_detailCancelToken?.isCancelled == true) return;

        if (state is VisitDetailLoaded) {
          emit(
            (state as VisitDetailLoaded).copyWith(
              isBackgroundUpdating: false,
              backgroundError: failure.message,
            ),
          );
        } else {
          emit(VisitError(message: failure.message));
        }
      },
      (freshVisit) {
        visitRepository.saveLocalVisitDetail(freshVisit);
        emit(VisitDetailLoaded(visit: freshVisit, isBackgroundUpdating: false));
      },
    );
  }

  Future<void> _onDeleteVisit(
    DeleteVisitEvent event,
    Emitter<VisitState> emit,
  ) async {
    final current = state;
    if (current is! VisitsLoaded) return;
    final previousVisits = current.visits;
    final updatedVisits = current.visits
        .where((v) => v.id != event.id)
        .toList();
    emit(current.copyWith(visits: updatedVisits));
    final result = await deleteVisitUseCase(DeleteVisitParams(id: event.id));
    result.fold(
      (failure) => emit(
        current.copyWith(
          visits: previousVisits,
          errorMessage: _failureMessage(failure),
        ),
      ),
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

  @override
  Future<void> close() {
    _visitsCancelToken?.cancel();
    _detailCancelToken?.cancel();
    return super.close();
  }
}
