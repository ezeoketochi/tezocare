import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/refill_repository.dart';

class MarkRefillContactedUseCase implements UseCase<void, MarkRefillContactedParams> {
  final RefillRepository repository;

  MarkRefillContactedUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkRefillContactedParams params) {
    return repository.markContacted(params.refillId);
  }
}

class MarkRefillContactedParams extends Equatable {
  final String refillId;

  const MarkRefillContactedParams({required this.refillId});

  @override
  List<Object> get props => [refillId];
}
