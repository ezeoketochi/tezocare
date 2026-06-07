import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/add_medication_usecase.dart';
import '../../domain/usecases/deactivate_medication_usecase.dart';
import '../../domain/usecases/get_patient_medications_usecase.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final AddMedicationUseCase addMedicationUseCase;
  final GetPatientMedicationsUseCase getPatientMedicationsUseCase;
  final UpdateMedicationUseCase updateMedicationUseCase;
  final DeactivateMedicationUseCase deactivateMedicationUseCase;
  CancelToken? _medicationsCancelToken;

  MedicationBloc({
    required this.addMedicationUseCase,
    required this.getPatientMedicationsUseCase,
    required this.updateMedicationUseCase,
    required this.deactivateMedicationUseCase,
  }) : super(const MedicationInitial()) {
    on<AddMedicationEvent>(_onAddMedication);
    on<GetPatientMedicationsEvent>(_onGetPatientMedications);
    on<UpdateMedicationEvent>(_onUpdateMedication);
    on<DeactivateMedicationEvent>(_onDeactivateMedication);
    on<ClearMedicationError>(_onClearMedicationError);
  }

  Future<void> _onAddMedication(
    AddMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());
    final result = await addMedicationUseCase(
      AddMedicationParams(medication: event.medication),
    );
    result.fold(
      (failure) => emit(MedicationError(message: _failureMessage(failure))),
      (medication) => emit(MedicationAdded(medication: medication)),
    );
  }

  Future<void> _onGetPatientMedications(
    GetPatientMedicationsEvent event,
    Emitter<MedicationState> emit,
  ) async {
    _medicationsCancelToken?.cancel();
    _medicationsCancelToken = CancelToken();

    if (state is MedicationsLoaded) {
      final current = state as MedicationsLoaded;
      emit(current.copyWith(isBackgroundUpdating: true));
    } else {
      final cached = await getPatientMedicationsUseCase.repository
          .getLocalPatientMedications(event.patientId);
      if (cached != null) {
        emit(MedicationsLoaded(
          medications: cached,
          isBackgroundUpdating: true,
        ));
      } else {
        emit(const MedicationLoading());
      }
    }

    final result = await getPatientMedicationsUseCase(
      GetPatientMedicationsParams(
        patientId: event.patientId,
        cancelToken: _medicationsCancelToken,
      ),
    );

    result.fold(
      (failure) {
        if (_medicationsCancelToken!.isCancelled) return;
        if (state is MedicationsLoaded) {
          final current = state as MedicationsLoaded;
          emit(current.copyWith(
            isBackgroundUpdating: false,
            backgroundError: _failureMessage(failure),
          ));
        } else {
          emit(MedicationError(message: _failureMessage(failure)));
        }
      },
      (medications) {
        if (_medicationsCancelToken!.isCancelled) return;
        getPatientMedicationsUseCase.repository
            .saveLocalPatientMedications(event.patientId, medications);
        emit(MedicationsLoaded(
          medications: medications,
          isBackgroundUpdating: false,
        ));
      },
    );
  }

  Future<void> _onUpdateMedication(
    UpdateMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    final current = state;
    if (current is! MedicationsLoaded) return;
    final previousMedications = current.medications;
    final updatedMedications = current.medications.map((m) {
      return m.id == event.medication.id ? event.medication : m;
    }).toList();
    emit(current.copyWith(medications: updatedMedications));
    final result = await updateMedicationUseCase(
      UpdateMedicationParams(medication: event.medication),
    );
    result.fold(
      (failure) => emit(current.copyWith(medications: previousMedications, errorMessage: _failureMessage(failure))),
      (_) => null,
    );
  }

  Future<void> _onDeactivateMedication(
    DeactivateMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    final current = state;
    if (current is! MedicationsLoaded) return;
    final previousMedications = current.medications;
    final updatedMedications = current.medications.where((m) => m.id != event.id).toList();
    emit(current.copyWith(medications: updatedMedications));
    final result = await deactivateMedicationUseCase(
      DeactivateMedicationParams(id: event.id),
    );
    result.fold(
      (failure) => emit(current.copyWith(medications: previousMedications, errorMessage: _failureMessage(failure))),
      (_) => null,
    );
  }

  void _onClearMedicationError(ClearMedicationError event, Emitter<MedicationState> emit) {
    final current = state;
    if (current is MedicationsLoaded) {
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

  @override
  Future<void> close() {
    _medicationsCancelToken?.cancel();
    return super.close();
  }
}
