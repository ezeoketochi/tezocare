import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/due_refill.dart';
import '../repositories/refill_repository.dart';

class GetDueRefillsUseCase implements UseCase<List<DueRefill>, GetDueRefillsParams> {
  final RefillRepository repository;

  GetDueRefillsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<DueRefill>>> call(GetDueRefillsParams params) {
    return repository.getDueRefills(filter: params.filter, days: params.days);
  }
}

class GetDueRefillsParams extends Equatable {
  final String? filter;
  final int? days;

  const GetDueRefillsParams({this.filter, this.days});

  @override
  List<Object?> get props => [filter, days];
}
