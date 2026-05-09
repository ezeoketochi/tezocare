import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/medication/domain/entities/medication.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/add_medication_usecase.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/deactivate_medication_usecase.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/get_patient_medications_usecase.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/update_medication_usecase.dart';
import 'package:tezocare_mobile/features/medication/presentation/bloc/medication_bloc.dart';
import 'package:tezocare_mobile/features/medication/presentation/bloc/medication_event.dart';
import 'package:tezocare_mobile/features/medication/presentation/bloc/medication_state.dart';

class MockAddMedicationUseCase extends Mock implements AddMedicationUseCase {}
class MockGetPatientMedicationsUseCase extends Mock implements GetPatientMedicationsUseCase {}
class MockUpdateMedicationUseCase extends Mock implements UpdateMedicationUseCase {}
class MockDeactivateMedicationUseCase extends Mock implements DeactivateMedicationUseCase {}

void main() {
  late MockAddMedicationUseCase addMedicationUseCase;
  late MockGetPatientMedicationsUseCase getPatientMedicationsUseCase;
  late MockUpdateMedicationUseCase updateMedicationUseCase;
  late MockDeactivateMedicationUseCase deactivateMedicationUseCase;

  setUpAll(() {
    registerFallbackValue(const AddMedicationParams(
      medication: Medication(id: 0, patientId: 0, name: '', isActive: false),
    ));
    registerFallbackValue(const GetPatientMedicationsParams(patientId: 0));
    registerFallbackValue(const UpdateMedicationParams(
      medication: Medication(id: 0, patientId: 0, name: '', isActive: false),
    ));
    registerFallbackValue(const DeactivateMedicationParams(id: 0));
  });

  setUp(() {
    addMedicationUseCase = MockAddMedicationUseCase();
    getPatientMedicationsUseCase = MockGetPatientMedicationsUseCase();
    updateMedicationUseCase = MockUpdateMedicationUseCase();
    deactivateMedicationUseCase = MockDeactivateMedicationUseCase();
  });

  const medication = Medication(id: 1, patientId: 1, name: 'Amoxicillin', isActive: true);
  const medications = [medication];

  group('MedicationBloc', () {
    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, MedicationsLoaded] when getPatientMedications succeeds',
      build: () {
        when(() => getPatientMedicationsUseCase(any())).thenAnswer(
          (_) async => const Right(medications),
        );
        return MedicationBloc(
          addMedicationUseCase: addMedicationUseCase,
          getPatientMedicationsUseCase: getPatientMedicationsUseCase,
          updateMedicationUseCase: updateMedicationUseCase,
          deactivateMedicationUseCase: deactivateMedicationUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetPatientMedicationsEvent(patientId: 1)),
      expect: () => [
        const MedicationLoading(),
        const MedicationsLoaded(medications: medications),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, MedicationAdded] when addMedication succeeds',
      build: () {
        when(() => addMedicationUseCase(any())).thenAnswer(
          (_) async => const Right(medication),
        );
        return MedicationBloc(
          addMedicationUseCase: addMedicationUseCase,
          getPatientMedicationsUseCase: getPatientMedicationsUseCase,
          updateMedicationUseCase: updateMedicationUseCase,
          deactivateMedicationUseCase: deactivateMedicationUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddMedicationEvent(medication: medication)),
      expect: () => [
        const MedicationLoading(),
        const MedicationAdded(medication: medication),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, MedicationDeactivated] when deactivate succeeds',
      build: () {
        when(() => deactivateMedicationUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return MedicationBloc(
          addMedicationUseCase: addMedicationUseCase,
          getPatientMedicationsUseCase: getPatientMedicationsUseCase,
          updateMedicationUseCase: updateMedicationUseCase,
          deactivateMedicationUseCase: deactivateMedicationUseCase,
        );
      },
      act: (bloc) => bloc.add(const DeactivateMedicationEvent(id: 1)),
      expect: () => [
        const MedicationLoading(),
        const MedicationDeactivated(),
      ],
    );

    blocTest<MedicationBloc, MedicationState>(
      'emits [Loading, MedicationError] when addMedication fails',
      build: () {
        when(() => addMedicationUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );
        return MedicationBloc(
          addMedicationUseCase: addMedicationUseCase,
          getPatientMedicationsUseCase: getPatientMedicationsUseCase,
          updateMedicationUseCase: updateMedicationUseCase,
          deactivateMedicationUseCase: deactivateMedicationUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddMedicationEvent(medication: medication)),
      expect: () => [
        const MedicationLoading(),
        const MedicationError(message: 'Server error'),
      ],
    );
  });
}
