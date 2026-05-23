import 'package:dartz/dartz.dart';
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
    return repository.getDueFollowUps(days: params.days);
  }
}

class GetDueFollowUpsParams extends Equatable {
  final int? days;

  const GetDueFollowUpsParams({this.days});

  @override
  List<Object?> get props => [days];
}
