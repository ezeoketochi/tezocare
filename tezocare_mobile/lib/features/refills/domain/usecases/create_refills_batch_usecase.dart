import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/refill_repository.dart';

class CreateRefillsBatchUseCase
    implements UseCase<List<String>, CreateRefillsBatchParams> {
  final RefillRepository repository;

  CreateRefillsBatchUseCase({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(CreateRefillsBatchParams params) {
    return repository.createRefillsBatch(params.medications);
  }
}

class CreateRefillsBatchParams extends Equatable {
  final List<Map<String, dynamic>> medications;

  const CreateRefillsBatchParams({required this.medications});

  @override
  List<Object> get props => [medications];
}
