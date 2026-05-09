import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<PatientModel> createPatient(PatientModel patient);
  Future<List<PatientModel>> getPatients({int page = 1});
  Future<PatientModel> getPatientDetail(int id);
  Future<List<PatientModel>> searchPatients(String query);
  Future<PatientModel> updatePatient(PatientModel patient);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient dioClient;

  PatientRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PatientModel> createPatient(PatientModel patient) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.patients,
        data: patient.toJson(),
      );
      return PatientModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to create patient');
    }
  }

  @override
  Future<List<PatientModel>> getPatients({int page = 1}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.patients,
        queryParameters: {'page': page},
      );
      final dataList = response.data['data'] as List<dynamic>;
      return dataList
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch patients');
    }
  }

  @override
  Future<PatientModel> getPatientDetail(int id) async {
    try {
      final response = await dioClient.dio.get('${ApiConstants.patients}/$id');
      return PatientModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to fetch patient detail',
      );
    }
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.patients,
        queryParameters: {'search': query},
      );
      final dataList = response.data['data'] as List<dynamic>;
      return dataList
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to search patients');
    }
  }

  @override
  Future<PatientModel> updatePatient(PatientModel patient) async {
    try {
      final response = await dioClient.dio.put(
        '${ApiConstants.patients}/${patient.id}',
        data: patient.toJson(),
      );
      return PatientModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to update patient');
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
