import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/due_refill.dart';
import '../../domain/repositories/refill_repository.dart';
import '../datasources/refill_remote_datasource.dart';

class RefillRepositoryImpl implements RefillRepository {
  final RefillRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RefillRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DueRefill>>> getDueRefills({String? filter, int? days}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getDueRefills(filter: filter, days: days);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> markContacted(String refillId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.markContacted(refillId);
      return const Right(null);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> markRefilled(String refillId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.markRefilled(refillId);
      return const Right(null);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<String>>> createRefillsBatch(
    List<Map<String, dynamic>> medications,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.createRefillsBatch(medications);
      final ids = (result['ids'] as List<dynamic>).cast<String>();
      return Right(ids);
    } catch (e) {
      return handleException(e);
    }
  }
}
