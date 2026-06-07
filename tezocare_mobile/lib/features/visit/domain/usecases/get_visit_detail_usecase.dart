import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetVisitDetailUseCase implements UseCase<Visit, GetVisitDetailParams> {
  final VisitRepository repository;

  GetVisitDetailUseCase({required this.repository});

  @override
  Future<Either<Failure, Visit>> call(GetVisitDetailParams params) {
    return repository.getVisitDetail(
      params.id,
      cancelToken: params.cancelToken,
    );
  }
}

class GetVisitDetailParams {
  final String id;
  final CancelToken? cancelToken;

  const GetVisitDetailParams({
    required this.id,
    this.cancelToken,
  });
}
