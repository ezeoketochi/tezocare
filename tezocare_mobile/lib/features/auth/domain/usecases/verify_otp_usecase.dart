import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) {
    return repository.verifyOtp(email: params.email, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}
