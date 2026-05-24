import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/visit_repository.dart';

class DeleteVisitUseCase implements UseCase<void, DeleteVisitParams> {
  final VisitRepository repository;

  DeleteVisitUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteVisitParams params) {
    return repository.deleteVisit(params.id);
  }
}

class DeleteVisitParams {
  final String id;

  const DeleteVisitParams({required this.id});
}
