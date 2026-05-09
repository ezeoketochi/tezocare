import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/visit_model.dart';
import '../models/vitals_model.dart';

abstract class VisitRemoteDataSource {
  Future<VisitModel> createVisit({
    required VisitModel visit,
    VitalsModel? vitals,
  });
  Future<List<VisitModel>> getPatientVisits(int patientId);
  Future<VisitModel> getVisitDetail(int id);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final DioClient dioClient;

  VisitRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<VisitModel> createVisit({
    required VisitModel visit,
    VitalsModel? vitals,
  }) async {
    try {
      final data = visit.toJson();
      if (vitals != null) {
        data['vitals'] = vitals.toJson();
      }
      final response = await dioClient.dio.post(
        ApiConstants.visits,
        data: data,
      );
      return VisitModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to create visit');
    }
  }

  @override
  Future<List<VisitModel>> getPatientVisits(int patientId) async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConstants.patients}/$patientId${ApiConstants.visits}',
      );
      final dataList = response.data['data'] as List<dynamic>;
      return dataList
          .map((e) => VisitModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to fetch visits');
    }
  }

  @override
  Future<VisitModel> getVisitDetail(int id) async {
    try {
      final response = await dioClient.dio.get('${ApiConstants.visits}/$id');
      return VisitModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to fetch visit detail',
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
