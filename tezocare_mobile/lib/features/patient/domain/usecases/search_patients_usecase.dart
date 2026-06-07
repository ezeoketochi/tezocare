import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class SearchPatientsUseCase
    implements UseCase<List<Patient>, SearchPatientsParams> {
  final PatientRepository repository;

  SearchPatientsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Patient>>> call(SearchPatientsParams params) {
    return repository.searchPatients(params.query, cancelToken: params.cancelToken);
  }
}

class SearchPatientsParams {
  final String query;
  final CancelToken? cancelToken;

  const SearchPatientsParams({required this.query, this.cancelToken});
}
