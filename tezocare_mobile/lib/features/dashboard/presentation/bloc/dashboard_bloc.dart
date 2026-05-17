import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
  }) : super(const DashboardInitial()) {
    on<GetDashboardStatsEvent>(_onGetDashboardStats);
  }

  Future<void> _onGetDashboardStats(
    GetDashboardStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final statsResult = await getDashboardStatsUseCase(const NoParams());

    statsResult.fold(
      (failure) => emit(DashboardError(message: _failureMessage(failure))),
      (stats) => emit(
        DashboardLoaded(stats: stats),
      ),
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
