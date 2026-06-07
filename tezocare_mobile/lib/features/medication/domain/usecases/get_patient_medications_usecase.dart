import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetPatientMedicationsUseCase
    implements UseCase<List<Medication>, GetPatientMedicationsParams> {
  final MedicationRepository repository;

  GetPatientMedicationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Medication>>> call(
    GetPatientMedicationsParams params,
  ) {
    return repository.getPatientMedications(
      params.patientId,
      cancelToken: params.cancelToken,
    );
  }
}

class GetPatientMedicationsParams {
  final String patientId;
  final CancelToken? cancelToken;

  const GetPatientMedicationsParams({
    required this.patientId,
    this.cancelToken,
  });
}
