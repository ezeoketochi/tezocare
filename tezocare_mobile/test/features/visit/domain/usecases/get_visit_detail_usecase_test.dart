import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/visit.dart';
import 'package:tezocare_mobile/features/visit/domain/repositories/visit_repository.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/get_visit_detail_usecase.dart';

class MockVisitRepository extends Mock implements VisitRepository {}

void main() {
  late MockVisitRepository repository;
  late GetVisitDetailUseCase useCase;

  setUp(() {
    repository = MockVisitRepository();
    useCase = GetVisitDetailUseCase(repository: repository);
  });

  final visit = Visit(id: 1, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'completed');

  test('should call repository.getVisitDetail with id', () async {
    when(() => repository.getVisitDetail(1))
        .thenAnswer((_) async => Right(visit));

    final result = await useCase(const GetVisitDetailParams(id: 1));

    expect(result, Right(visit));
    verify(() => repository.getVisitDetail(1)).called(1);
  });

  test('should return NotFoundFailure when not found', () async {
    when(() => repository.getVisitDetail(999)).thenAnswer(
      (_) async => Left(NotFoundFailure(message: 'Visit not found')),
    );

    final result = await useCase(const GetVisitDetailParams(id: 999));

    expect(result, Left(NotFoundFailure(message: 'Visit not found')));
  });
}
