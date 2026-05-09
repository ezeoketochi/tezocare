import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/update_patient_usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repository;
  late UpdatePatientUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Patient(id: 0, name: '', species: '', isActive: false));
  });

  setUp(() {
    repository = MockPatientRepository();
    useCase = UpdatePatientUseCase(repository: repository);
  });

  const patient = Patient(id: 1, name: 'Buddy Updated', species: 'Canine', isActive: true);

  test('should call repository.updatePatient', () async {
    when(() => repository.updatePatient(any()))
        .thenAnswer((_) async => const Right(patient));

    final result = await useCase(UpdatePatientParams(patient: patient));

    expect(result, const Right(patient));
    verify(() => repository.updatePatient(patient)).called(1);
  });

  test('should return NotFoundFailure when patient not found', () async {
    when(() => repository.updatePatient(any())).thenAnswer(
      (_) async => Left(NotFoundFailure(message: 'Patient not found')),
    );

    final result = await useCase(UpdatePatientParams(patient: patient));

    expect(result, Left(NotFoundFailure(message: 'Patient not found')));
  });
}
