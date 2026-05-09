import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/medication/domain/entities/medication.dart';
import 'package:tezocare_mobile/features/medication/domain/repositories/medication_repository.dart';
import 'package:tezocare_mobile/features/medication/domain/usecases/get_patient_medications_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late GetPatientMedicationsUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = GetPatientMedicationsUseCase(repository: repository);
  });

  final medications = [
    const Medication(id: 1, patientId: 1, name: 'Amoxicillin', isActive: true),
  ];

  test('should call repository.getPatientMedications with patientId', () async {
    when(() => repository.getPatientMedications(1))
        .thenAnswer((_) async => Right(medications));

    final result = await useCase(const GetPatientMedicationsParams(patientId: 1));

    expect(result, Right(medications));
    verify(() => repository.getPatientMedications(1)).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.getPatientMedications(1)).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error')),
    );

    final result = await useCase(const GetPatientMedicationsParams(patientId: 1));

    expect(result, Left(ServerFailure(message: 'Server error')));
  });
}
