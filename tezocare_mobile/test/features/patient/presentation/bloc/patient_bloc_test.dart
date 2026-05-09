import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/create_patient_usecase.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/get_patient_detail_usecase.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/get_patients_usecase.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/search_patients_usecase.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/update_patient_usecase.dart';
import 'package:tezocare_mobile/features/patient/presentation/bloc/patient_bloc.dart';
import 'package:tezocare_mobile/features/patient/presentation/bloc/patient_event.dart';
import 'package:tezocare_mobile/features/patient/presentation/bloc/patient_state.dart';

class MockCreatePatientUseCase extends Mock implements CreatePatientUseCase {}
class MockGetPatientsUseCase extends Mock implements GetPatientsUseCase {}
class MockGetPatientDetailUseCase extends Mock implements GetPatientDetailUseCase {}
class MockSearchPatientsUseCase extends Mock implements SearchPatientsUseCase {}
class MockUpdatePatientUseCase extends Mock implements UpdatePatientUseCase {}

void main() {
  late MockCreatePatientUseCase createPatientUseCase;
  late MockGetPatientsUseCase getPatientsUseCase;
  late MockGetPatientDetailUseCase getPatientDetailUseCase;
  late MockSearchPatientsUseCase searchPatientsUseCase;
  late MockUpdatePatientUseCase updatePatientUseCase;

  setUpAll(() {
    registerFallbackValue(const GetPatientsParams());
    registerFallbackValue(const GetPatientDetailParams(id: 0));
    registerFallbackValue(const CreatePatientParams(patient: Patient(id: 0, name: '', species: '', isActive: false)));
    registerFallbackValue(const UpdatePatientParams(patient: Patient(id: 0, name: '', species: '', isActive: false)));
    registerFallbackValue(const SearchPatientsParams(query: ''));
  });

  setUp(() {
    createPatientUseCase = MockCreatePatientUseCase();
    getPatientsUseCase = MockGetPatientsUseCase();
    getPatientDetailUseCase = MockGetPatientDetailUseCase();
    searchPatientsUseCase = MockSearchPatientsUseCase();
    updatePatientUseCase = MockUpdatePatientUseCase();
  });

  const patient = Patient(id: 1, name: 'Buddy', species: 'Canine', isActive: true);
  const patients = [patient];

  group('PatientBloc', () {
    blocTest<PatientBloc, PatientState>(
      'emits [Loading, PatientsLoaded] when getPatients succeeds',
      build: () {
        when(() => getPatientsUseCase(any())).thenAnswer(
          (_) async => const Right(patients),
        );
        return PatientBloc(
          createPatientUseCase: createPatientUseCase,
          getPatientsUseCase: getPatientsUseCase,
          getPatientDetailUseCase: getPatientDetailUseCase,
          searchPatientsUseCase: searchPatientsUseCase,
          updatePatientUseCase: updatePatientUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetPatientsEvent(page: 1)),
      expect: () => [
        const PatientLoading(),
        const PatientsLoaded(patients: patients, currentPage: 1),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'emits [Loading, PatientDetailLoaded] when getPatientDetail succeeds',
      build: () {
        when(() => getPatientDetailUseCase(any())).thenAnswer(
          (_) async => const Right(patient),
        );
        return PatientBloc(
          createPatientUseCase: createPatientUseCase,
          getPatientsUseCase: getPatientsUseCase,
          getPatientDetailUseCase: getPatientDetailUseCase,
          searchPatientsUseCase: searchPatientsUseCase,
          updatePatientUseCase: updatePatientUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetPatientDetailEvent(id: 1)),
      expect: () => [
        const PatientLoading(),
        const PatientDetailLoaded(patient: patient),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'emits [Loading, PatientCreated] when createPatient succeeds',
      build: () {
        when(() => createPatientUseCase(any())).thenAnswer(
          (_) async => const Right(patient),
        );
        return PatientBloc(
          createPatientUseCase: createPatientUseCase,
          getPatientsUseCase: getPatientsUseCase,
          getPatientDetailUseCase: getPatientDetailUseCase,
          searchPatientsUseCase: searchPatientsUseCase,
          updatePatientUseCase: updatePatientUseCase,
        );
      },
      act: (bloc) => bloc.add(const CreatePatientEvent(patient: patient)),
      expect: () => [
        const PatientLoading(),
        const PatientCreated(patient: patient),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'emits [Loading, PatientError] when createPatient fails',
      build: () {
        when(() => createPatientUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );
        return PatientBloc(
          createPatientUseCase: createPatientUseCase,
          getPatientsUseCase: getPatientsUseCase,
          getPatientDetailUseCase: getPatientDetailUseCase,
          searchPatientsUseCase: searchPatientsUseCase,
          updatePatientUseCase: updatePatientUseCase,
        );
      },
      act: (bloc) => bloc.add(const CreatePatientEvent(patient: patient)),
      expect: () => [
        const PatientLoading(),
        const PatientError(message: 'Server error'),
      ],
    );
  });
}
