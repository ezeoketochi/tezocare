import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/medication/domain/entities/medication.dart';
import 'package:tezocare_mobile/features/medication/domain/repositories/medication_repository.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/add_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late AddMedicationUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Medication(id: 0, patientId: 0, name: '', isActive: false));
  });

  setUp(() {
    repository = MockMedicationRepository();
    useCase = AddMedicationUseCase(repository: repository);
  });

  const medication = Medication(
    id: 1,
    patientId: 1,
    name: 'Amoxicillin',
    isActive: true,
  );

  const params = AddMedicationParams(medication: medication);

  test('should call repository.addMedication', () async {
    when(() => repository.addMedication(any()))
        .thenAnswer((_) async => const Right(medication));

    final result = await useCase(params);

    expect(result, const Right(medication));
    verify(() => repository.addMedication(medication)).called(1);
  });

  test('should return ValidationFailure on validation error', () async {
    when(() => repository.addMedication(any())).thenAnswer(
      (_) async => Left(ValidationFailure(message: 'Name required')),
    );

    final result = await useCase(params);

    expect(result, Left(ValidationFailure(message: 'Name required')));
  });
}
