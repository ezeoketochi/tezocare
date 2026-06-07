import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/follow_up_repository_impl.dart';
import '../../domain/usecases/get_due_follow_ups_usecase.dart';
import '../../domain/usecases/mark_follow_up_done_usecase.dart';
import 'follow_up_event.dart';
import 'follow_up_state.dart';

class FollowUpBloc extends Bloc<FollowUpEvent, FollowUpState> {
  final GetDueFollowUpsUseCase getDueFollowUpsUseCase;
  final MarkFollowUpDoneUseCase markFollowUpDoneUseCase;
  final FollowUpRepositoryImpl followUpRepository;
  CancelToken? _followUpsCancelToken;

  FollowUpBloc({
    required this.getDueFollowUpsUseCase,
    required this.markFollowUpDoneUseCase,
    required this.followUpRepository,
  }) : super(const FollowUpInitial()) {
    on<GetDueFollowUpsEvent>(_onGetDueFollowUps);
    on<MarkFollowUpDoneEvent>(_onMarkFollowUpDone);
    on<ClearFollowUpError>(_onClearFollowUpError);
  }

  Future<void> _onGetDueFollowUps(
    GetDueFollowUpsEvent event,
    Emitter<FollowUpState> emit,
  ) async {
    _followUpsCancelToken?.cancel();
    _followUpsCancelToken = event.cancelToken ?? CancelToken();

    if (state is FollowUpLoaded) {
      emit((state as FollowUpLoaded).copyWith(isBackgroundUpdating: true));
    } else {
      final localData = await followUpRepository.getLocalDueFollowUps();
      if (localData.isNotEmpty) {
        final overdue = localData.where((f) => f.followupStatus == 'overdue').length;
        final dueToday = localData.where((f) => f.followupStatus == 'due_today').length;
        final upcoming = localData.where((f) => f.followupStatus == 'upcoming').length;
        emit(FollowUpLoaded(
          followUps: localData,
          total: localData.length,
          overdue: overdue,
          dueToday: dueToday,
          upcoming: upcoming,
          isBackgroundUpdating: true,
        ));
      }
    }

    final result = await getDueFollowUpsUseCase(
      GetDueFollowUpsParams(days: event.days, cancelToken: _followUpsCancelToken),
    );

    result.fold(
      (failure) {
        if (_followUpsCancelToken!.isCancelled) return;
        if (state is FollowUpLoaded) {
          emit((state as FollowUpLoaded).copyWith(
            isBackgroundUpdating: false,
            backgroundError: _failureMessage(failure),
          ));
        } else {
          emit(FollowUpError(message: _failureMessage(failure)));
        }
      },
      (followUps) {
        if (_followUpsCancelToken!.isCancelled) return;
        final overdue = followUps.where((f) => f.followupStatus == 'overdue').length;
        final dueToday = followUps.where((f) => f.followupStatus == 'due_today').length;
        final upcoming = followUps.where((f) => f.followupStatus == 'upcoming').length;
        emit(FollowUpLoaded(
          followUps: followUps,
          total: followUps.length,
          overdue: overdue,
          dueToday: dueToday,
          upcoming: upcoming,
          isBackgroundUpdating: false,
        ));
      },
    );
  }

  Future<void> _onMarkFollowUpDone(
    MarkFollowUpDoneEvent event,
    Emitter<FollowUpState> emit,
  ) async {
    final current = state;
    if (current is! FollowUpLoaded) return;
    final previousFollowUps = current.followUps;
    final updatedFollowUps = current.followUps.where((f) => f.visitId != event.visitId).toList();
    emit(current.copyWith(
      followUps: updatedFollowUps,
      total: current.total - 1,
    ));
    final result = await markFollowUpDoneUseCase(
      MarkFollowUpDoneParams(visitId: event.visitId, outcome: event.outcome),
    );
    result.fold(
      (failure) => emit(current.copyWith(followUps: previousFollowUps, total: current.total, errorMessage: _failureMessage(failure))),
      (_) => emit(current.copyWith(successMessage: 'Follow-up marked as done')),
    );
  }

  void _onClearFollowUpError(ClearFollowUpError event, Emitter<FollowUpState> emit) {
    final current = state;
    if (current is FollowUpLoaded) {
      emit(current.copyWith(errorMessage: null, successMessage: null));
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
    _followUpsCancelToken?.cancel();
    return super.close();
  }
}
