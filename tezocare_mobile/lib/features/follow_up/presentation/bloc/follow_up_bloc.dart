import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_due_follow_ups_usecase.dart';
import '../../domain/usecases/mark_follow_up_done_usecase.dart';
import 'follow_up_event.dart';
import 'follow_up_state.dart';

class FollowUpBloc extends Bloc<FollowUpEvent, FollowUpState> {
  final GetDueFollowUpsUseCase getDueFollowUpsUseCase;
  final MarkFollowUpDoneUseCase markFollowUpDoneUseCase;

  FollowUpBloc({
    required this.getDueFollowUpsUseCase,
    required this.markFollowUpDoneUseCase,
  }) : super(const FollowUpInitial()) {
    on<GetDueFollowUpsEvent>(_onGetDueFollowUps);
    on<MarkFollowUpDoneEvent>(_onMarkFollowUpDone);
  }

  Future<void> _onGetDueFollowUps(
    GetDueFollowUpsEvent event,
    Emitter<FollowUpState> emit,
  ) async {
    emit(const FollowUpLoading());
    final result = await getDueFollowUpsUseCase(
      GetDueFollowUpsParams(days: event.days),
    );
    result.fold(
      (failure) => emit(FollowUpError(message: _failureMessage(failure))),
      (followUps) {
        final overdue = followUps.where((f) => f.followupStatus == 'overdue').length;
        final dueToday = followUps.where((f) => f.followupStatus == 'due_today').length;
        final upcoming = followUps.where((f) => f.followupStatus == 'upcoming').length;
        emit(FollowUpLoaded(
          followUps: followUps,
          total: followUps.length,
          overdue: overdue,
          dueToday: dueToday,
          upcoming: upcoming,
        ));
      },
    );
  }

  Future<void> _onMarkFollowUpDone(
    MarkFollowUpDoneEvent event,
    Emitter<FollowUpState> emit,
  ) async {
    emit(const FollowUpLoading());
    final result = await markFollowUpDoneUseCase(
      MarkFollowUpDoneParams(visitId: event.visitId, outcome: event.outcome),
    );
    result.fold(
      (failure) => emit(FollowUpError(message: _failureMessage(failure))),
      (_) {
        emit(FollowUpMarkedDone(visitId: event.visitId));
        add(const GetDueFollowUpsEvent());
      },
    );
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
