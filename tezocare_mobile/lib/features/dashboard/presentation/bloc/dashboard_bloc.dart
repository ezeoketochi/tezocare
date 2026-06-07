import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  CancelToken? _statsCancelToken;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
  }) : super(const DashboardInitial()) {
    on<GetDashboardStatsEvent>(_onGetDashboardStats);
  }

  Future<void> _onGetDashboardStats(
    GetDashboardStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    _statsCancelToken?.cancel();
    _statsCancelToken = CancelToken();

    if (state is DashboardLoaded) {
      final current = state as DashboardLoaded;
      emit(current.copyWith(isBackgroundUpdating: true));
    } else {
      final cached = await getDashboardStatsUseCase.repository.getLocalDashboardStats();
      if (cached != null) {
        emit(DashboardLoaded(
          stats: cached,
          isBackgroundUpdating: true,
        ));
      } else {
        emit(const DashboardLoading());
      }
    }

    final result = await getDashboardStatsUseCase(
      GetDashboardStatsParams(cancelToken: _statsCancelToken),
    );

    result.fold(
      (failure) {
        if (_statsCancelToken!.isCancelled) return;
        if (state is DashboardLoaded) {
          final current = state as DashboardLoaded;
          emit(current.copyWith(
            isBackgroundUpdating: false,
            backgroundError: _failureMessage(failure),
          ));
        } else {
          emit(DashboardError(message: _failureMessage(failure)));
        }
      },
      (stats) {
        if (_statsCancelToken!.isCancelled) return;
        getDashboardStatsUseCase.repository.saveLocalDashboardStats(stats);
        emit(DashboardLoaded(
          stats: stats,
          isBackgroundUpdating: false,
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

  @override
  Future<void> close() {
    _statsCancelToken?.cancel();
    return super.close();
  }
}
