import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientsUseCase
    implements UseCase<List<Patient>, GetPatientsParams> {
  final PatientRepository repository;

  GetPatientsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Patient>>> call(GetPatientsParams params) {
    return repository.getPatients(
      page: params.page,
      search: params.search,
      status: params.status,
      cancelToken: params.cancelToken,
    );
  }
}

class GetPatientsParams {
  final int page;
  final String? search;
  final String? status;
  final CancelToken? cancelToken;

  const GetPatientsParams({this.page = 1, this.search, this.status, this.cancelToken});
}
