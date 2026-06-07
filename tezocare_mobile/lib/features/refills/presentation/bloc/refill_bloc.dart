import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_refills_batch_usecase.dart';
import '../../domain/usecases/get_due_refills_usecase.dart';
import '../../domain/usecases/mark_refill_contacted_usecase.dart';
import '../../domain/usecases/mark_refill_fulfilled_usecase.dart';
import 'refill_event.dart';
import 'refill_state.dart';

class RefillBloc extends Bloc<RefillEvent, RefillState> {
  final GetDueRefillsUseCase getDueRefillsUseCase;
  final MarkRefillContactedUseCase markRefillContactedUseCase;
  final MarkRefillFulfilledUseCase markRefillFulfilledUseCase;
  final CreateRefillsBatchUseCase createRefillsBatchUseCase;

  RefillBloc({
    required this.getDueRefillsUseCase,
    required this.markRefillContactedUseCase,
    required this.markRefillFulfilledUseCase,
    required this.createRefillsBatchUseCase,
  }) : super(const RefillInitial()) {
    on<GetDueRefillsEvent>(_onGetDueRefills);
    on<MarkAsContacted>(_onMarkAsContacted);
    on<MarkAsRefilled>(_onMarkAsRefilled);
    on<CreateRefillsBatch>(_onCreateRefillsBatch);
    on<ClearRefillError>(_onClearRefillError);
  }

  Future<void> _onGetDueRefills(
    GetDueRefillsEvent event,
    Emitter<RefillState> emit,
  ) async {
    emit(const RefillLoading());
    final result = await getDueRefillsUseCase(
      GetDueRefillsParams(filter: event.filter, days: event.days),
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
        emit(
          RefillLoaded(
            refills: refills,
            total: refills.length,
            overdue: overdue,
            dueToday: dueToday,
            outreach: outreach,
            activeFilter: event.filter,
            activeDays: event.days,
          ),
        );
      },
    );
  }

  Future<void> _onMarkAsContacted(
    MarkAsContacted event,
    Emitter<RefillState> emit,
  ) async {
    final current = state;
    if (current is! RefillLoaded) return;

    final previousRefills = current.refills;

    // Optimistically update your exact unique properties mapping
    final updatedRefills = current.refills.map((refill) {
      if (refill.refillId == event.refillId) {
        return refill.copyWith(
          contactStatus: 'contacted',
          lastActionAt: DateTime.now(), // Snappy instant UI timestamp update
        );
      }
      return refill;
    }).toList();

    // Update in-memory state instantly without a loading spinner
    emit(current.copyWith(refills: updatedRefills));

    final result = await markRefillContactedUseCase(
      MarkRefillContactedParams(refillId: event.refillId),
    );

    result.fold((failure) {
      emit(
        current.copyWith(
          refills: previousRefills,
          errorMessage: _failureMessage(failure),
        ),
      );
    }, (_) => null);
  }

  Future<void> _onMarkAsRefilled(
    MarkAsRefilled event,
    Emitter<RefillState> emit,
  ) async {
    final current = state;
    if (current is! RefillLoaded) return;
    final previousRefills = current.refills;
    final updatedRefills = current.refills.map((refill) {
      if (refill.refillId == event.refillId) {
        return refill.copyWith(
          refillStatus: 'fulfilled',
          lastActionAt: DateTime.now(),
        );
      }
      return refill;
    }).toList();
    emit(current.copyWith(refills: updatedRefills));
    final result = await markRefillFulfilledUseCase(
      MarkRefillFulfilledParams(refillId: event.refillId),
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          refills: previousRefills,
          errorMessage: _failureMessage(failure),
        ),
      ),
      (_) => null,
    );
  }

  Future<void> _onCreateRefillsBatch(
    CreateRefillsBatch event,
    Emitter<RefillState> emit,
  ) async {
    emit(const RefillLoading());
    final result = await createRefillsBatchUseCase(
      CreateRefillsBatchParams(medications: event.medications),
    );
    result.fold(
      (failure) => emit(RefillError(message: _failureMessage(failure))),
      (ids) => emit(RefillBatchCreated(refillIds: ids)),
    );
  }

  void _onClearRefillError(ClearRefillError event, Emitter<RefillState> emit) {
    final current = state;
    if (current is RefillLoaded) {
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
