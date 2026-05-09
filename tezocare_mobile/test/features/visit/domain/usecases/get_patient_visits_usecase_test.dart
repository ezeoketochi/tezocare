import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/visit.dart';
import 'package:tezocare_mobile/features/visit/domain/repositories/visit_repository.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/get_patient_visits_usecase.dart';

class MockVisitRepository extends Mock implements VisitRepository {}

void main() {
  late MockVisitRepository repository;
  late GetPatientVisitsUseCase useCase;

  setUp(() {
    repository = MockVisitRepository();
    useCase = GetPatientVisitsUseCase(repository: repository);
  });

  final visits = [
    Visit(id: 1, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'completed'),
  ];

  test('should call repository.getPatientVisits with patientId', () async {
    when(() => repository.getPatientVisits(1))
        .thenAnswer((_) async => Right(visits));

    final result = await useCase(const GetPatientVisitsParams(patientId: 1));

    expect(result, Right(visits));
    verify(() => repository.getPatientVisits(1)).called(1);
  });

  test('should return ServerFailure on error', () async {
    when(() => repository.getPatientVisits(1)).thenAnswer(
      (_) async => Left(ServerFailure(message: 'Server error')),
    );

    final result = await useCase(const GetPatientVisitsParams(patientId: 1));

    expect(result, Left(ServerFailure(message: 'Server error')));
  });
}
