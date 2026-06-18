import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/due_follow_up.dart';
import '../repositories/follow_up_repository.dart';

class GetDueFollowUpsUseCase implements UseCase<List<DueFollowUp>, GetDueFollowUpsParams> {
  final FollowUpRepository repository;

  GetDueFollowUpsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<DueFollowUp>>> call(GetDueFollowUpsParams params) {
    return repository.getDueFollowUps(
      filter: params.filter,
      days: params.days,
      cancelToken: params.cancelToken,
    );
  }
}

class GetDueFollowUpsParams extends Equatable {
  final String? filter;
  final int? days;
  final CancelToken? cancelToken;

  const GetDueFollowUpsParams({this.filter, this.days, this.cancelToken});

  @override
  List<Object?> get props => [filter, days, cancelToken];
}
