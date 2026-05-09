import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/medication/domain/repositories/medication_repository.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/deactivate_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late DeactivateMedicationUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = DeactivateMedicationUseCase(repository: repository);
  });

  const params = DeactivateMedicationParams(id: 1);

  test('should call repository.deactivateMedication with id', () async {
    when(() => repository.deactivateMedication(1))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(params);

    expect(result, const Right(null));
    verify(() => repository.deactivateMedication(1)).called(1);
  });

  test('should return NotFoundFailure when not found', () async {
    when(() => repository.deactivateMedication(999)).thenAnswer(
      (_) async => Left(NotFoundFailure(message: 'Medication not found')),
    );

    final result = await useCase(const DeactivateMedicationParams(id: 999));

    expect(result, Left(NotFoundFailure(message: 'Medication not found')));
  });
}
