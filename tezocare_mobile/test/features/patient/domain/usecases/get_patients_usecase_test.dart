import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/get_patients_usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repository;
  late GetPatientsUseCase useCase;

  setUp(() {
    repository = MockPatientRepository();
    useCase = GetPatientsUseCase(repository: repository);
  });

  final patients = [
    const Patient(id: 1, name: 'Buddy', species: 'Canine', isActive: true),
    const Patient(id: 2, name: 'Mittens', species: 'Feline', isActive: true),
  ];

  test('should call repository.getPatients with page', () async {
    when(() => repository.getPatients(page: 1))
        .thenAnswer((_) async => Right(patients));

    final result = await useCase(const GetPatientsParams(page: 1));

    expect(result, Right(patients));
    verify(() => repository.getPatients(page: 1)).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.getPatients(page: 1)).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error')),
    );

    final result = await useCase(const GetPatientsParams(page: 1));

    expect(result, Left(ServerFailure(message: 'Server error')));
  });
}
