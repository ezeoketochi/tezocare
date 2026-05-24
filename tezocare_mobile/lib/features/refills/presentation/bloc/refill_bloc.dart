import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_due_refills_usecase.dart';
import '../../domain/usecases/mark_refill_contacted_usecase.dart';
import '../../domain/usecases/mark_refill_fulfilled_usecase.dart';
import 'refill_event.dart';
import 'refill_state.dart';

class RefillBloc extends Bloc<RefillEvent, RefillState> {
  final GetDueRefillsUseCase getDueRefillsUseCase;
  final MarkRefillContactedUseCase markRefillContactedUseCase;
  final MarkRefillFulfilledUseCase markRefillFulfilledUseCase;

  RefillBloc({
    required this.getDueRefillsUseCase,
    required this.markRefillContactedUseCase,
    required this.markRefillFulfilledUseCase,
  }) : super(const RefillInitial()) {
    on<GetDueRefillsEvent>(_onGetDueRefills);
    on<MarkAsContacted>(_onMarkAsContacted);
    on<MarkAsRefilled>(_onMarkAsRefilled);
  }

  Future<void> _onGetDueRefills(
    GetDueRefillsEvent event,
    Emitter<RefillState> emit,
  ) async {
    emit(const RefillLoading());
    final result = await getDueRefillsUseCase(
      GetDueRefillsParams(filter: event.filter),
    );
    result.fold(
      (failure) => emit(RefillError(message: _failureMessage(failure))),
      (refills) {
        final overdue = refills
            .where((r) => r.escalatedStatus == 'Phase 3 (Overdue)')
            .length;
        final dueToday = refills
            .where((r) => r.escalatedStatus == 'Phase 2 (Due Today)')
            .length;
        final outreach = refills
            .where((r) => r.escalatedStatus == 'Phase 1 (Outreach)')
            .length;
        emit(RefillLoaded(
          refills: refills,
          total: refills.length,
          overdue: overdue,
          dueToday: dueToday,
          outreach: outreach,
          activeFilter: event.filter,
        ));
      },
    );
  }

  Future<void> _onMarkAsContacted(
    MarkAsContacted event,
    Emitter<RefillState> emit,
  ) async {
    final current = state;
    if (current is! RefillLoaded) return;
    emit(const RefillLoading());
    final result = await markRefillContactedUseCase(
      MarkRefillContactedParams(refillId: event.refillId),
    );
    result.fold(
      (failure) => emit(RefillError(message: _failureMessage(failure))),
      (_) {
        add(GetDueRefillsEvent(filter: current.activeFilter));
      },
    );
  }

  Future<void> _onMarkAsRefilled(
    MarkAsRefilled event,
    Emitter<RefillState> emit,
  ) async {
    final current = state;
    if (current is! RefillLoaded) return;
    emit(const RefillLoading());
    final result = await markRefillFulfilledUseCase(
      MarkRefillFulfilledParams(refillId: event.refillId),
    );
    result.fold(
      (failure) => emit(RefillError(message: _failureMessage(failure))),
      (_) {
        add(GetDueRefillsEvent(filter: current.activeFilter));
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
