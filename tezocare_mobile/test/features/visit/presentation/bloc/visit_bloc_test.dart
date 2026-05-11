import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tezocare_mobile/core/error/failures.dart';
import 'package:tezocare_mobile/features/visit/domain/entities/visit.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/create_visit_usecase.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/get_patient_visits_usecase.dart';
import 'package:tezocare_mobile/features/visit/domain/usecases/get_visit_detail_usecase.dart';
import 'package:tezocare_mobile/features/visit/presentation/bloc/visit_bloc.dart';
import 'package:tezocare_mobile/features/visit/presentation/bloc/visit_event.dart';
import 'package:tezocare_mobile/features/visit/presentation/bloc/visit_state.dart';

class MockCreateVisitUseCase extends Mock implements CreateVisitUseCase {}
class MockGetPatientVisitsUseCase extends Mock implements GetPatientVisitsUseCase {}
class MockGetVisitDetailUseCase extends Mock implements GetVisitDetailUseCase {}

void main() {
  late MockCreateVisitUseCase createVisitUseCase;
  late MockGetPatientVisitsUseCase getPatientVisitsUseCase;
  late MockGetVisitDetailUseCase getVisitDetailUseCase;

  setUpAll(() {
    registerFallbackValue(CreateVisitParams(
      visit: Visit(id: 0, patientId: 0, staffId: 0, visitDate: DateTime(2025, 1, 1), status: ''),
      vitals: null,
    ));
    registerFallbackValue(const GetPatientVisitsParams(patientId: 0));
    registerFallbackValue(const GetVisitDetailParams(id: 0));
  });

  setUp(() {
    createVisitUseCase = MockCreateVisitUseCase();
    getPatientVisitsUseCase = MockGetPatientVisitsUseCase();
    getVisitDetailUseCase = MockGetVisitDetailUseCase();
  });

  final visit = Visit(id: 1, patientId: 1, staffId: 1, visitDate: DateTime(2025, 3, 10), status: 'completed');

  group('VisitBloc', () {
    blocTest<VisitBloc, VisitState>(
      'emits [Loading, VisitsLoaded] when getPatientVisits succeeds',
      build: () {
        when(() => getPatientVisitsUseCase(any())).thenAnswer(
          (_) async => Right(<Visit>[visit]),
        );
        return VisitBloc(
          createVisitUseCase: createVisitUseCase,
          getPatientVisitsUseCase: getPatientVisitsUseCase,
          getVisitDetailUseCase: getVisitDetailUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetPatientVisitsEvent(patientId: 1)),
      expect: () => [
        const VisitLoading(),
        VisitsLoaded(visits: [visit]),
      ],
    );

    blocTest<VisitBloc, VisitState>(
      'emits [Loading, VisitCreated] when createVisit succeeds',
      build: () {
        when(() => createVisitUseCase(any())).thenAnswer(
          (_) async =>         Right(visit),
        );
        return VisitBloc(
          createVisitUseCase: createVisitUseCase,
          getPatientVisitsUseCase: getPatientVisitsUseCase,
          getVisitDetailUseCase: getVisitDetailUseCase,
        );
      },
      act: (bloc) => bloc.add(CreateVisitEvent(visit: visit, vitals: null)),
      expect: () => [
        const VisitLoading(),
        VisitCreated(visit: visit),
      ],
    );

    blocTest<VisitBloc, VisitState>(
      'emits [Loading, VisitDetailLoaded] when getVisitDetail succeeds',
      build: () {
        when(() => getVisitDetailUseCase(any())).thenAnswer(
          (_) async => Right(visit),
        );
        return VisitBloc(
          createVisitUseCase: createVisitUseCase,
          getPatientVisitsUseCase: getPatientVisitsUseCase,
          getVisitDetailUseCase: getVisitDetailUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetVisitDetailEvent(id: 1)),
      expect: () => [
        const VisitLoading(),
        VisitDetailLoaded(visit: visit),
      ],
    );

    blocTest<VisitBloc, VisitState>(
      'emits [Loading, VisitError] when getVisitDetail fails',
      build: () {
        when(() => getVisitDetailUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Not found')),
        );
        return VisitBloc(
          createVisitUseCase: createVisitUseCase,
          getPatientVisitsUseCase: getPatientVisitsUseCase,
          getVisitDetailUseCase: getVisitDetailUseCase,
        );
      },
      act: (bloc) => bloc.add(const GetVisitDetailEvent(id: 999)),
      expect: () => [
        const VisitLoading(),
        const VisitError(message: 'Not found'),
      ],
    );
  });
}
