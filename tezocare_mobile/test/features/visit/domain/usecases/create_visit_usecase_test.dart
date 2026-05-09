import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/visit.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/vitals.dart';
import 'package:tezocare_mobile/features/visit/domain/repositories/visit_repository.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/create_visit_usecase.dart';

class MockVisitRepository extends Mock implements VisitRepository {}

void main() {
  late MockVisitRepository repository;
  late CreateVisitUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Visit(id: 0, patientId: 0, staffId: 0, visitDate: DateTime(2025, 1, 1), status: ''));
    registerFallbackValue(const Vitals());
  });

  setUp(() {
    repository = MockVisitRepository();
    useCase = CreateVisitUseCase(repository: repository);
  });

  final visit = Visit(
    id: 1,
    patientId: 1,
    staffId: 1,
    visitDate: DateTime(2025, 3, 10),
    status: 'completed',
  );

  final params = CreateVisitParams(visit: visit, vitals: null);

  test('should call repository.createVisit with visit and vitals', () async {
    when(() => repository.createVisit(visit: any(named: 'visit'), vitals: any(named: 'vitals')))
        .thenAnswer((_) async => Right(visit));

    final result = await useCase(params);

    expect(result, Right(visit));
    verify(() => repository.createVisit(visit: visit, vitals: null)).called(1);
  });

  test('should return ValidationFailure on validation error', () async {
    when(() => repository.createVisit(visit: any(named: 'visit'), vitals: any(named: 'vitals')))
        .thenAnswer((_) async => Left(ValidationFailure(message: 'Reason required')));

    final result = await useCase(params);

    expect(result, Left(ValidationFailure(message: 'Reason required')));
  });
}
