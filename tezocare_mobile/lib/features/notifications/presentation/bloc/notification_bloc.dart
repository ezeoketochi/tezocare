import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationState.initial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<ClearNotificationMessages>(_onClearMessages);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final hadData = state.notifications.isNotEmpty;
    if (!hadData) {
      emit(state.copyWith(status: NotificationLoadStatus.loading));
    }

    final result = await getNotificationsUseCase(const NoParams());

    result.fold(
      (failure) {
        if (!hadData) {
          emit(state.copyWith(
            status: NotificationLoadStatus.error,
            errorMessage: () => _failureMessage(failure),
          ));
        }
      },
      (notifications) {
        emit(state.copyWith(
          notifications: notifications,
          status: NotificationLoadStatus.loaded,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final updated = state.notifications.map((n) {
      if (n.id == event.notificationId && n.readAt == null) {
        return n.copyWith(readAt: DateTime.now());
      }
      return n;
    }).toList();

    emit(state.copyWith(
      notifications: updated,
      actionStatus: NotificationActionStatus.loading,
    ));

    final result = await markNotificationReadUseCase(
      MarkNotificationReadParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: NotificationActionStatus.failure,
        errorMessage: () => _failureMessage(failure),
      )),
      (_) => emit(state.copyWith(
        actionStatus: NotificationActionStatus.success,
      )),
    );
  }

  void _onClearMessages(
    ClearNotificationMessages event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
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
