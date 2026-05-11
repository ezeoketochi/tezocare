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
    emit(const MedicationLoading());
    final result = await getPatientMedicationsUseCase(
      GetPatientMedicationsParams(patientId: event.patientId),
    );
    result.fold(
      (failure) => emit(MedicationError(message: _failureMessage(failure))),
      (medications) => emit(MedicationsLoaded(medications: medications)),
    );
  }

  Future<void> _onUpdateMedication(
    UpdateMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());
    final result = await updateMedicationUseCase(
      UpdateMedicationParams(medication: event.medication),
    );
    result.fold(
      (failure) => emit(MedicationError(message: _failureMessage(failure))),
      (medication) => emit(MedicationUpdated(medication: medication)),
    );
  }

  Future<void> _onDeactivateMedication(
    DeactivateMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());
    final result = await deactivateMedicationUseCase(
      DeactivateMedicationParams(id: event.id),
    );
    result.fold(
      (failure) => emit(MedicationError(message: _failureMessage(failure))),
      (_) => emit(const MedicationDeactivated()),
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
