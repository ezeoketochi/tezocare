import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/patient/domain/entities/patient.dart';
import 'package:tezocare_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:tezocare_mobile/features/patient/domain/usecases/search_patients_usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repository;
  late SearchPatientsUseCase useCase;

  setUp(() {
    repository = MockPatientRepository();
    useCase = SearchPatientsUseCase(repository: repository);
  });

  final patients = [
    const Patient(id: 1, name: 'Buddy', species: 'Canine', isActive: true),
  ];

  test('should call repository.searchPatients with query', () async {
    when(() => repository.searchPatients('Buddy'))
        .thenAnswer((_) async => Right(patients));

    final result = await useCase(const SearchPatientsParams(query: 'Buddy'));

    expect(result, Right(patients));
    verify(() => repository.searchPatients('Buddy')).called(1);
  });

  test('should return empty list for no matches', () async {
    when(() => repository.searchPatients('Unknown'))
        .thenAnswer((_) async => const Right([]));

    final result = await useCase(const SearchPatientsParams(query: 'Unknown'));

    expect(result, const Right(<Patient>[]));
  });
}
