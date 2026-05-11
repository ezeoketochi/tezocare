import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_refills_due_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetRefillsDueUseCase getRefillsDueUseCase;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
    required this.getRefillsDueUseCase,
  }) : super(const DashboardInitial()) {
    on<GetDashboardStatsEvent>(_onGetDashboardStats);
    on<GetRefillsDueEvent>(_onGetRefillsDue);
  }

  Future<void> _onGetDashboardStats(
    GetDashboardStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final statsResult = await getDashboardStatsUseCase(const NoParams());
    final refillsResult = await getRefillsDueUseCase(const NoParams());

    statsResult.fold(
      (failure) => emit(DashboardError(message: _failureMessage(failure))),
      (stats) {
        refillsResult.fold(
          (failure) => emit(DashboardError(message: _failureMessage(failure))),
          (refills) => emit(
            DashboardLoaded(stats: stats, refillsDue: refills),
          ),
        );
      },
    );
  }

  Future<void> _onGetRefillsDue(
    GetRefillsDueEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await getRefillsDueUseCase(const NoParams());
    result.fold(
      (failure) => emit(DashboardError(message: _failureMessage(failure))),
      (refills) {
        final currentState = state;
        if (currentState is DashboardLoaded) {
          emit(DashboardLoaded(
            stats: currentState.stats,
            refillsDue: refills,
          ));
        }
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
