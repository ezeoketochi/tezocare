import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/staff.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<Staff, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  @override
  Future<Either<Failure, Staff>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
