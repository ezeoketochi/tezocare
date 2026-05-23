import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_up_repository.dart';

class MarkFollowUpDoneUseCase implements UseCase<void, MarkFollowUpDoneParams> {
  final FollowUpRepository repository;

  MarkFollowUpDoneUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkFollowUpDoneParams params) {
    return repository.markFollowUpDone(params.visitId, outcome: params.outcome);
  }
}

class MarkFollowUpDoneParams extends Equatable {
  final String visitId;
  final String outcome;

  const MarkFollowUpDoneParams({required this.visitId, required this.outcome});

  @override
  List<Object> get props => [visitId, outcome];
}
