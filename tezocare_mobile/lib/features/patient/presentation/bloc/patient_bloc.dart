import 'package:dio/dio.dart';
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

  CancelToken? _patientsCancelToken;
  CancelToken? _detailCancelToken;
  CancelToken? _searchCancelToken;

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
    _patientsCancelToken?.cancel();
    final cancelToken = CancelToken();
    _patientsCancelToken = cancelToken;

    final cached = getPatientsUseCase.repository.getCachedPatients(
      page: event.page,
      search: event.search,
      status: event.status,
    );

    if (cached != null && cached.isNotEmpty) {
      emit(
        PatientsLoaded(
          patients: cached,
          currentPage: event.page,
          isBackgroundUpdating: true,
        ),
      );
    } else {
      emit(const PatientLoading());
    }

    final result = await getPatientsUseCase(
      GetPatientsParams(
        page: event.page,
        search: event.search,
        status: event.status,
        cancelToken: cancelToken,
      ),
    );

    if (cancelToken.isCancelled) return;

    result.fold(
      (failure) {
        if (state is PatientsLoaded) {
          emit(
            (state as PatientsLoaded).copyWith(
              isBackgroundUpdating: false,
              backgroundError: _failureMessage(failure),
            ),
          );
        } else {
          emit(PatientError(message: _failureMessage(failure)));
        }
      },
      (patients) {
        getPatientsUseCase.repository.cachePatients(
          page: event.page,
          search: event.search,
          status: event.status,
          patients: patients,
        );
        emit(
          PatientsLoaded(
            patients: patients,
            currentPage: event.page,
            isBackgroundUpdating: false,
          ),
        );
      },
    );
  }

  Future<void> _onGetPatientDetail(
    GetPatientDetailEvent event,
    Emitter<PatientState> emit,
  ) async {
    _detailCancelToken?.cancel();
    final cancelToken = CancelToken();
    _detailCancelToken = cancelToken;

    final cached = getPatientDetailUseCase.repository.getCachedPatientDetail(
      event.id,
    );

    if (cached != null) {
      emit(PatientDetailLoaded(patient: cached, isBackgroundUpdating: true));
    } else {
      emit(const PatientLoading());
    }

    final result = await getPatientDetailUseCase(
      GetPatientDetailParams(id: event.id, cancelToken: cancelToken),
    );

    if (cancelToken.isCancelled) return;

    result.fold(
      (failure) {
        if (state is PatientDetailLoaded) {
          emit(
            (state as PatientDetailLoaded).copyWith(
              isBackgroundUpdating: false,
              backgroundError: _failureMessage(failure),
            ),
          );
        } else {
          emit(PatientError(message: _failureMessage(failure)));
        }
      },
      (patient) {
        getPatientDetailUseCase.repository.cachePatientDetail(
          event.id,
          patient,
        );
        emit(
          PatientDetailLoaded(patient: patient, isBackgroundUpdating: false),
        );
      },
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

    // ────────────────────────────────────────────────────────
    // SCENARIO 1: Updating from a List Screen (PatientsLoaded)
    // ────────────────────────────────────────────────────────
    if (current is PatientsLoaded) {
      final previousPatients = current.patients;

      // Optimistically update the list locally
      final updatedPatients = current.patients.map((p) {
        return p.id == event.patient.id ? event.patient : p;
      }).toList();

      // Step 1: Turn background loader ON and apply optimistic list update immediately
      emit(
        current.copyWith(patients: updatedPatients, isBackgroundUpdating: true),
      );

      // Step 2: Call the backend API on your EC2 instance
      final result = await updatePatientUseCase(
        UpdatePatientParams(patient: event.patient),
      );

      // Step 3: Evaluate the functional programming Either result cleanly
      result.fold(
        (failure) {
          // API Failed: Roll back to previous list state, turn off loader, set error strings
          emit(
            current.copyWith(
              patients: previousPatients,
              errorMessage: _failureMessage(failure),
              isBackgroundUpdating: false,
              backgroundError: _failureMessage(failure),
            ),
          );
        },
        (successData) {
          // API Succeeded: Keep the updated list, turn off loader, trip saveSuccess true
          emit(
            current.copyWith(
              patients: updatedPatients,
              isBackgroundUpdating: false,
              saveSuccess: true,
            ),
          );
        },
      );

      // ────────────────────────────────────────────────────────
      // SCENARIO 2: Updating from Form/Details Screen (PatientDetailLoaded)
      // ────────────────────────────────────────────────────────
    } else if (current is PatientDetailLoaded) {
      final previousPatient = current.patient;

      // Step 1: Optimistically show the updated data on the form fields and turn loader ON
      emit(
        current.copyWith(
          patient: event.patient,
          isBackgroundUpdating: true,
          saveSuccess:
              false, // Ensure this is explicitly cleared out when starting a new save
        ),
      );

      // Step 2: Call the backend API
      final result = await updatePatientUseCase(
        UpdatePatientParams(patient: event.patient),
      );

      // Step 3: Evaluate the result before telling the UI everything is okay
      result.fold(
        (failure) {
          // API Failed: Revert to the original database patient model row layout data
          emit(
            current.copyWith(
              patient: previousPatient,
              errorMessage: _failureMessage(failure),
              isBackgroundUpdating: false,
              backgroundError: _failureMessage(failure),
              saveSuccess: false,
            ),
          );
        },
        (successData) {
          // API Succeeded: Turn off loader, confirm saveSuccess true to trigger the UI Navigator.pop()
          emit(
            current.copyWith(
              isBackgroundUpdating: false,
              saveSuccess: true,
              backgroundError: null,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> _onSearchPatients(
    SearchPatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    _searchCancelToken?.cancel();
    final cancelToken = CancelToken();
    _searchCancelToken = cancelToken;

    emit(const PatientLoading());

    final result = await searchPatientsUseCase(
      SearchPatientsParams(query: event.query, cancelToken: cancelToken),
    );

    if (cancelToken.isCancelled) return;

    result.fold(
      (failure) => emit(PatientError(message: _failureMessage(failure))),
      (patients) =>
          emit(PatientsLoaded(patients: patients, isBackgroundUpdating: false)),
    );
  }

  void _onClearPatientError(
    ClearPatientError event,
    Emitter<PatientState> emit,
  ) {
    final current = state;
    if (current is PatientsLoaded) {
      emit(current.copyWith(errorMessage: null, backgroundError: null));
    } else if (current is PatientDetailLoaded) {
      emit(current.copyWith(errorMessage: null, backgroundError: null));
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
    _patientsCancelToken?.cancel();
    _detailCancelToken?.cancel();
    _searchCancelToken?.cancel();
    return super.close();
  }
}
