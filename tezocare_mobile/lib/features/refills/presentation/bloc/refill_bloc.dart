import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_due_refills_usecase.dart';
import 'refill_event.dart';
import 'refill_state.dart';

class RefillBloc extends Bloc<RefillEvent, RefillState> {
  final GetDueRefillsUseCase getDueRefillsUseCase;

  RefillBloc({required this.getDueRefillsUseCase}) : super(const RefillInitial()) {
    on<GetDueRefillsEvent>(_onGetDueRefills);
  }

  Future<void> _onGetDueRefills(
    GetDueRefillsEvent event,
    Emitter<RefillState> emit,
  ) async {
    emit(const RefillLoading());
    final result = await getDueRefillsUseCase(
      GetDueRefillsParams(days: event.days),
    );
    result.fold(
      (failure) => emit(RefillError(message: _failureMessage(failure))),
      (refills) {
        final overdue = refills.where((r) => r.refillStatus == 'overdue').length;
        final dueToday = refills.where((r) => r.refillStatus == 'due_today').length;
        final upcoming = refills.where((r) => r.refillStatus == 'upcoming').length;
        emit(RefillLoaded(
          refills: refills,
          total: refills.length,
          overdue: overdue,
          dueToday: dueToday,
          upcoming: upcoming,
        ));
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
