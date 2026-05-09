import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/get_patient_detail_usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repository;
  late GetPatientDetailUseCase useCase;

  setUp(() {
    repository = MockPatientRepository();
    useCase = GetPatientDetailUseCase(repository: repository);
  });

  const patient = Patient(id: 1, name: 'Buddy', species: 'Canine', isActive: true);

  test('should call repository.getPatientDetail with id', () async {
    when(() => repository.getPatientDetail(1))
        .thenAnswer((_) async => const Right(patient));

    final result = await useCase(const GetPatientDetailParams(id: 1));

    expect(result, const Right(patient));
    verify(() => repository.getPatientDetail(1)).called(1);
  });

  test('should return NotFoundFailure when not found', () async {
    when(() => repository.getPatientDetail(999)).thenAnswer(
      (_) async => Left(NotFoundFailure(message: 'Patient not found')),
    );

    final result = await useCase(const GetPatientDetailParams(id: 999));

    expect(result, Left(NotFoundFailure(message: 'Patient not found')));
  });
}
