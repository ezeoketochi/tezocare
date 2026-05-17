import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/visit_model.dart';

abstract class VisitRemoteDataSource {
  Future<VisitModel> createVisit(VisitModel visit);
  Future<VisitModel> updateVisit(String id, VisitModel visit);
  Future<List<VisitModel>> getPatientVisits(String patientId);
  Future<VisitModel> getVisitDetail(String id);
  Future<VisitModel> completeVisit(String id);
  Future<VisitModel> referVisit(String id, {required String destination, required String reason});
  Future<VisitModel> markFollowUpDone(String id);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final DioClient dioClient;

  VisitRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<VisitModel> createVisit(VisitModel visit) async {
    try {
      final createPayload = <String, dynamic>{
        'patient_id': visit.patientId,
        'visit_date': visit.visitDate.toIso8601String().split('T')[0],
      };
      final response = await dioClient.dio.post(
        ApiConstants.visits,
        data: createPayload,
      );
      final createdData = response.data['data'] as Map<String, dynamic>;
      final visitId = createdData['id'] as String;

      final updated = await _updateVisitData(visitId, visit);
      return updated;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to create visit');
    }
  }

  Future<VisitModel> _updateVisitData(String visitId, VisitModel visit) async {
    final updatePayload = <String, dynamic>{};
    final fullJson = visit.toJson();

    const clinicalKeys = [
      'chief_complaints', 'medication_history', 'vitals',
      'test_results', 'clinical_assessment', 'medications_dispensed',
      'counselling_advice', 'follow_up', 'referral',
    ];
    for (final key in clinicalKeys) {
      if (fullJson.containsKey(key)) {
        updatePayload[key] = fullJson[key];
      }
    }

    if (updatePayload.isNotEmpty) {
      await dioClient.dio.patch(
        '${ApiConstants.visits}/$visitId',
        data: updatePayload,
      );
    }

    final getResponse = await dioClient.dio.get(
      '${ApiConstants.visits}/$visitId',
    );
    return VisitModel.fromJson(
      getResponse.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<VisitModel> updateVisit(String id, VisitModel visit) async {
    try {
      final result = await _updateVisitData(id, visit);
      return result;
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to update visit');
    }
  }

  @override
  Future<List<VisitModel>> getPatientVisits(String patientId) async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConstants.patients}/$patientId/visits',
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
  Future<VisitModel> getVisitDetail(String id) async {
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

  @override
  Future<VisitModel> completeVisit(String id) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.visits}/$id/complete',
      );
      return VisitModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to complete visit');
    }
  }

  @override
  Future<VisitModel> referVisit(String id, {required String destination, required String reason}) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.visits}/$id/refer',
        data: {'destination': destination, 'reason': reason},
      );
      return VisitModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Failed to refer patient');
    }
  }

  @override
  Future<VisitModel> markFollowUpDone(String id) async {
    try {
      final response = await dioClient.dio.patch(
        '${ApiConstants.visits}/$id/followup-done',
      );
      return VisitModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        defaultMessage: 'Failed to mark follow-up done',
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
