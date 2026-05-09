import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  Future<void> _onGetPatients(
    GetPatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await getPatientsUseCase(
      GetPatientsParams(page: event.page),
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
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
      (failure) => emit(PatientError(message: failure.message)),
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
      (failure) => emit(PatientError(message: failure.message)),
      (patient) => emit(PatientCreated(patient: patient)),
    );
  }

  Future<void> _onUpdatePatient(
    UpdatePatientEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    final result = await updatePatientUseCase(
      UpdatePatientParams(patient: event.patient),
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (patient) => emit(PatientUpdated(patient: patient)),
    );
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
      (failure) => emit(PatientError(message: failure.message)),
      (patients) => emit(PatientsLoaded(patients: patients)),
    );
  }
}
