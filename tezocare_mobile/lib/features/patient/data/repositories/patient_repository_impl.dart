import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;

  PatientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  String _listCacheKey({int page = 1, String? search, String? status}) =>
      'patient_list:$page:${search ?? ''}:${status ?? ''}';

  String _detailCacheKey(String id) => 'patient_detail:$id';

  @override
  Future<Either<Failure, Patient>> createPatient(Patient patient) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final patientModel = PatientModel(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth ?? DateTime(2000, 1, 1),
        gender: patient.gender,
        phone: patient.phone,
        address: patient.address,
        state: patient.state,
        city: patient.city,
        occupation: patient.occupation,
        bloodGroup: patient.bloodGroup,
        genotype: patient.genotype,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        isActive: patient.isActive,
      );
      final result = await remoteDataSource.createPatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> getPatients({int page = 1, String? search, String? status, CancelToken? cancelToken}) async {
    try {
      final result = await remoteDataSource.getPatients(
        page: page,
        search: search,
        status: status,
        cancelToken: cancelToken,
      );
      cachePatients(page: page, search: search, status: status, patients: result);
      return Right(result);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Left(ServerFailure(message: 'Request cancelled'));
      }
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Patient>> getPatientDetail(String id, {CancelToken? cancelToken}) async {
    try {
      final result = await remoteDataSource.getPatientDetail(id, cancelToken: cancelToken);
      cachePatientDetail(id, result);
      return Right(result);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Left(ServerFailure(message: 'Request cancelled'));
      }
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> searchPatients(String query, {CancelToken? cancelToken}) async {
    try {
      final result = await remoteDataSource.searchPatients(query, cancelToken: cancelToken);
      return Right(result);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Left(ServerFailure(message: 'Request cancelled'));
      }
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Patient>> updatePatient(Patient patient) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final patientModel = PatientModel(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth ?? DateTime(2000, 1, 1),
        gender: patient.gender,
        phone: patient.phone,
        address: patient.address,
        state: patient.state,
        city: patient.city,
        occupation: patient.occupation,
        bloodGroup: patient.bloodGroup,
        genotype: patient.genotype,
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        emergencyContactName: patient.emergencyContactName,
        emergencyContactPhone: patient.emergencyContactPhone,
        isActive: patient.isActive,
      );
      final result = await remoteDataSource.updatePatient(patientModel);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  List<Patient>? getCachedPatients({int page = 1, String? search, String? status}) {
    final key = _listCacheKey(page: page, search: search, status: status);
    final cached = cacheService.getAs<String>(key);
    if (cached == null) return null;
    final List<dynamic> jsonList = jsonDecode(cached) as List<dynamic>;
    return jsonList
        .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Patient? getCachedPatientDetail(String id) {
    final key = _detailCacheKey(id);
    final cached = cacheService.getAs<String>(key);
    if (cached == null) return null;
    return PatientModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  @override
  void cachePatients({int page = 1, String? search, String? status, required List<Patient> patients}) {
    final key = _listCacheKey(page: page, search: search, status: status);
    final jsonList = patients.map((p) => (p as PatientModel).toJson()).toList();
    cacheService.put(key, jsonEncode(jsonList));
  }

  @override
  void cachePatientDetail(String id, Patient patient) {
    final key = _detailCacheKey(id);
    cacheService.put(key, jsonEncode((patient as PatientModel).toJson()));
  }
}
