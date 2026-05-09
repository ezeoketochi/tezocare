import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/create_patient_usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repository;
  late CreatePatientUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Patient(id: 0, name: '', species: '', isActive: false));
  });

  setUp(() {
    repository = MockPatientRepository();
    useCase = CreatePatientUseCase(repository: repository);
  });

  const patient = Patient(
    id: 0,
    name: 'Buddy',
    species: 'Canine',
    isActive: true,
  );

  const createdPatient = Patient(
    id: 1,
    name: 'Buddy',
    species: 'Canine',
    isActive: true,
  );

  test('should call repository.createPatient', () async {
    when(() => repository.createPatient(any()))
        .thenAnswer((_) async => const Right(createdPatient));

    final result = await useCase(CreatePatientParams(patient: patient));

    expect(result, const Right(createdPatient));
    verify(() => repository.createPatient(patient)).called(1);
  });

  test('should return ValidationFailure on validation error', () async {
    when(() => repository.createPatient(any())).thenAnswer(
      (_) async => Left(ValidationFailure(message: 'Name required')),
    );

    final result = await useCase(CreatePatientParams(patient: patient));

    expect(result, Left(ValidationFailure(message: 'Name required')));
  });
}
