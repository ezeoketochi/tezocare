import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      email: params.email,
      otp: params.otp,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, otp, newPassword];
}
