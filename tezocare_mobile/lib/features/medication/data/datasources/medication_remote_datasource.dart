import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<MedicationModel> addMedication(MedicationModel medication);
  Future<List<MedicationModel>> getPatientMedications(int patientId);
  Future<MedicationModel> updateMedication(MedicationModel medication);
  Future<void> deactivateMedication(int id);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final DioClient dioClient;

  MedicationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.medications,
        data: medication.toJson(),
      );
      return MedicationModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to add medication');
    }
  }

  @override
  Future<List<MedicationModel>> getPatientMedications(int patientId) async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConstants.patients}/$patientId${ApiConstants.medications}',
      );
      final dataList = response.data['data'] as List<dynamic>;
      return dataList
          .map((e) =>
              MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to fetch medications',
      );
    }
  }

  @override
  Future<MedicationModel> updateMedication(MedicationModel medication) async {
    try {
      final response = await dioClient.dio.put(
        '${ApiConstants.medications}/${medication.id}',
        data: medication.toJson(),
      );
      return MedicationModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to update medication');
    }
  }

  @override
  Future<void> deactivateMedication(int id) async {
    try {
      await dioClient.dio.delete('${ApiConstants.medications}/$id');
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to deactivate medication',
      );
    }
  }

  Exception _mapDioException(DioException e, {required String defaultMessage}) {
    final customException = e.error;
    if (customException is UnauthorizedException) return customException;
    if (customException is ValidationException) return customException;
    if (customException is PermissionException) return customException;
    if (customException is NotFoundException) return customException;
    if (customException is NetworkException) return customException;

    return ServerException(
      message: e.response?.data['message'] as String? ??
          e.response?.data['detail'] as String? ??
          defaultMessage,
      statusCode: e.response?.statusCode,
    );
  }
}
