import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tezocare_mobile/features/follow_up/domain/repositories/follow_up_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_due_follow_ups_usecase.dart';
import '../../domain/usecases/mark_follow_up_done_usecase.dart';
import 'follow_up_event.dart';
import 'follow_up_state.dart';

class FollowUpBloc extends Bloc<FollowUpEvent, FollowUpState> {
  final GetDueFollowUpsUseCase getDueFollowUpsUseCase;
  final MarkFollowUpDoneUseCase markFollowUpDoneUseCase;
  final FollowUpRepository followUpRepository;
  CancelToken? _followUpsCancelToken;

  FollowUpBloc({
    required this.getDueFollowUpsUseCase,
    required this.markFollowUpDoneUseCase,
    required this.followUpRepository,
  }) : super(FollowUpStateContainer.initial()) {
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

    // Safely cast once at the top
    final current = state as FollowUpStateContainer;

    // 1. Instantly show loading state
    emit(current.copyWith(status: FollowUpStatus.loading));

    // 2. Load local cache to keep UI responsive while network fetches
    final localData = await followUpRepository.getLocalDueFollowUps();
    if (localData.isNotEmpty) {
      emit(
        current.copyWith(
          followUps: localData,
          total: localData.length,
          overdue: localData.where((f) => f.followupStatus == 'overdue').length,
          dueToday: localData
              .where((f) => f.followupStatus == 'due_today')
              .length,
          upcoming: localData
              .where((f) => f.followupStatus == 'upcoming')
              .length,
          status: FollowUpStatus.loaded,
        ),
      );
    }

    // 3. Hit your EC2 Backend server API
    final result = await getDueFollowUpsUseCase(
      GetDueFollowUpsParams(
        days: event.days,
        cancelToken: _followUpsCancelToken,
      ),
    );

    result.fold(
      (failure) {
        if (_followUpsCancelToken!.isCancelled) return;
        emit(
          current.copyWith(
            status: localData.isNotEmpty
                ? FollowUpStatus.loaded
                : FollowUpStatus.error,
            errorMessage: () => _failureMessage(failure),
          ),
        );
      },
      (followUps) {
        if (_followUpsCancelToken!.isCancelled) return;
        emit(
          current.copyWith(
            followUps: followUps,
            total: followUps.length,
            overdue: followUps
                .where((f) => f.followupStatus == 'overdue')
                .length,
            dueToday: followUps
                .where((f) => f.followupStatus == 'due_today')
                .length,
            upcoming: followUps
                .where((f) => f.followupStatus == 'upcoming')
                .length,
            status: FollowUpStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> _onMarkFollowUpDone(
    MarkFollowUpDoneEvent event,
    Emitter<FollowUpState> emit,
  ) async {
    if (state is! FollowUpStateContainer) return;
    final previousState =
        state as FollowUpStateContainer; // ◄ Cache the entire state snapshot

    // Calculate new localized metric updates for the optimistic view
    final updatedFollowUps = previousState.followUps
        .where((f) => f.visitId != event.visitId)
        .toList();

    emit(
      previousState.copyWith(
        followUps: updatedFollowUps,
        total: previousState.total - 1,
        overdue:
            previousState.followUps
                    .firstWhere((f) => f.visitId == event.visitId)
                    .followupStatus ==
                'overdue'
            ? previousState.overdue - 1
            : previousState.overdue,
        dueToday:
            previousState.followUps
                    .firstWhere((f) => f.visitId == event.visitId)
                    .followupStatus ==
                'due_today'
            ? previousState.dueToday - 1
            : previousState.dueToday,
        upcoming:
            previousState.followUps
                    .firstWhere((f) => f.visitId == event.visitId)
                    .followupStatus ==
                'upcoming'
            ? previousState.upcoming - 1
            : previousState.upcoming,
        actionStatus: ActionStatus.loading,
      ),
    );

    final result = await markFollowUpDoneUseCase(
      MarkFollowUpDoneParams(visitId: event.visitId, outcome: event.outcome),
    );

    result.fold(
      // ◄ Error: Just emit the unchanged previousState snapshot! It resets everything instantly.
      (failure) => emit(
        previousState.copyWith(
          actionStatus: ActionStatus.failure,
          errorMessage: () => _failureMessage(failure),
        ),
      ),
      (update) => emit(
        (state as FollowUpStateContainer).copyWith(
          successMessage: () => 'Follow-up marked as done',
          actionStatus: ActionStatus.success,
        ),
      ),
    );
  }

  void _onClearFollowUpError(
    ClearFollowUpError event,
    Emitter<FollowUpState> emit,
  ) {
    final current = state;
    if (current is FollowUpStateContainer) {
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
