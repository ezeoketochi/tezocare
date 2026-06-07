import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_patient_usecase.dart';
import '../../domain/usecases/get_patient_detail_usecase.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/search_patients_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final CreatePatientUseCase createPatientUseCase;
  final GetPatientsUseCase getPatientsUseCase;
  final GetPatientDetailUseCase getPatientDetailUseCase;
  final SearchPatientsUseCase searchPatientsUseCase;
  final UpdatePatientUseCase updatePatientUseCase;

  PatientBloc({
    required this.createPatientUseCase,
    required this.getPatientsUseCase,
    required this.getPatientDetailUseCase,
    required this.searchPatientsUseCase,
    required this.updatePatientUseCase,
  }) : super(const PatientInitial()) {
    on<GetPatientsEvent>(_onGetPatients);
    on<GetPatientDetailEvent>(_onGetPatientDetail);
    on<CreatePatientEvent>(_onCreatePatient);
    on<UpdatePatientEvent>(_onUpdatePatient);
    on<SearchPatientsEvent>(_onSearchPatients);
    on<ClearPatientError>(_onClearPatientError);
  }

  Future<void> _onGetPatients(
    GetPatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await getPatientsUseCase(
      GetPatientsParams(page: event.page, search: event.search, status: event.status),
    );
    result.fold(
      (failure) => emit(PatientError(message: _failureMessage(failure))),
      (patients) => emit(PatientsLoaded(patients: patients, currentPage: event.page)),
    );
  }

  Future<void> _onGetPatientDetail(
    GetPatientDetailEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await getPatientDetailUseCase(
      GetPatientDetailParams(id: event.id),
    );
    result.fold(
      (failure) => emit(PatientError(message: _failureMessage(failure))),
      (patient) => emit(PatientDetailLoaded(patient: patient)),
    );
  }

  Future<void> _onCreatePatient(
    CreatePatientEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await createPatientUseCase(
      CreatePatientParams(patient: event.patient),
    );
    result.fold(
      (failure) => emit(PatientError(message: _failureMessage(failure))),
      (patient) => emit(PatientCreated(patient: patient)),
    );
  }

  Future<void> _onUpdatePatient(
    UpdatePatientEvent event,
    Emitter<PatientState> emit,
  ) async {
    final current = state;
    if (current is PatientsLoaded) {
      final previousPatients = current.patients;
      final updatedPatients = current.patients.map((p) {
        return p.id == event.patient.id ? event.patient : p;
      }).toList();
      emit(current.copyWith(patients: updatedPatients));
      final result = await updatePatientUseCase(
        UpdatePatientParams(patient: event.patient),
      );
      result.fold(
        (failure) => emit(current.copyWith(patients: previousPatients, errorMessage: _failureMessage(failure))),
        (_) => null,
      );
    } else if (current is PatientDetailLoaded) {
      final previousPatient = current.patient;
      emit(current.copyWith(patient: event.patient));
      final result = await updatePatientUseCase(
        UpdatePatientParams(patient: event.patient),
      );
      result.fold(
        (failure) => emit(current.copyWith(patient: previousPatient, errorMessage: _failureMessage(failure))),
        (_) => null,
      );
    }
  }

  Future<void> _onSearchPatients(
    SearchPatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await searchPatientsUseCase(
      SearchPatientsParams(query: event.query),
    );
    result.fold(
      (failure) => emit(PatientError(message: _failureMessage(failure))),
      (patients) => emit(PatientsLoaded(patients: patients)),
    );
  }

  void _onClearPatientError(ClearPatientError event, Emitter<PatientState> emit) {
    final current = state;
    if (current is PatientsLoaded) {
      emit(current.copyWith(errorMessage: null));
    } else if (current is PatientDetailLoaded) {
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
