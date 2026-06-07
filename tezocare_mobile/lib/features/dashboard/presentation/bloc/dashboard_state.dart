import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final bool isBackgroundUpdating;
  final String? backgroundError;

  const DashboardLoaded({
    required this.stats,
    this.isBackgroundUpdating = false,
    this.backgroundError,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    bool? isBackgroundUpdating,
    String? backgroundError,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      isBackgroundUpdating: isBackgroundUpdating ?? this.isBackgroundUpdating,
      backgroundError: backgroundError,
    );
  }

  @override
  List<Object?> get props => [stats, isBackgroundUpdating, backgroundError];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
