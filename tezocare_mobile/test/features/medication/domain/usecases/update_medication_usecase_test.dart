import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/medication/domain/entities/medication.dart';
import 'package:tezocare_mobile/features/medication/domain/repositories/medication_repository.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/update_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late UpdateMedicationUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Medication(id: 0, patientId: 0, name: '', isActive: false));
  });

  setUp(() {
    repository = MockMedicationRepository();
    useCase = UpdateMedicationUseCase(repository: repository);
  });

  const medication = Medication(
    id: 1,
    patientId: 1,
    name: 'Amoxicillin',
    dosage: '500mg',
    isActive: true,
  );

  const params = UpdateMedicationParams(medication: medication);

  test('should call repository.updateMedication', () async {
    when(() => repository.updateMedication(any()))
        .thenAnswer((_) async => const Right(medication));

    final result = await useCase(params);

    expect(result, const Right(medication));
    verify(() => repository.updateMedication(medication)).called(1);
  });

  test('should return NotFoundFailure when not found', () async {
    when(() => repository.updateMedication(any())).thenAnswer(
      (_) async => Left(NotFoundFailure(message: 'Medication not found')),
    );

    final result = await useCase(params);

    expect(result, Left(NotFoundFailure(message: 'Medication not found')));
  });
}
