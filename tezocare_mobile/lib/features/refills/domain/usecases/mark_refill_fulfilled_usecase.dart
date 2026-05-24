import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/refill_repository.dart';

class MarkRefillFulfilledUseCase implements UseCase<void, MarkRefillFulfilledParams> {
  final RefillRepository repository;

  MarkRefillFulfilledUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkRefillFulfilledParams params) {
    return repository.markRefilled(params.refillId);
  }
}

class MarkRefillFulfilledParams extends Equatable {
  final String refillId;

  const MarkRefillFulfilledParams({required this.refillId});

  @override
  List<Object> get props => [refillId];
}
