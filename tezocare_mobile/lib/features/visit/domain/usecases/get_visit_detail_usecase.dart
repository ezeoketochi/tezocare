import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetVisitDetailUseCase implements UseCase<Visit, GetVisitDetailParams> {
  final VisitRepository repository;

  GetVisitDetailUseCase({required this.repository});

  @override
  Future<Either<Failure, Visit>> call(GetVisitDetailParams params) {
    return repository.getVisitDetail(params.id);
  }
}

class GetVisitDetailParams {
  final int id;

  const GetVisitDetailParams({required this.id});
}
