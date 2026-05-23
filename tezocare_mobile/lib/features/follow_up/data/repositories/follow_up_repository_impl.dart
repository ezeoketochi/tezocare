import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/due_follow_up.dart';
import '../../domain/repositories/follow_up_repository.dart';
import '../datasources/follow_up_remote_datasource.dart';

class FollowUpRepositoryImpl implements FollowUpRepository {
  final FollowUpRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FollowUpRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DueFollowUp>>> getDueFollowUps({int? days}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getDueFollowUps(days: days);
      return Right(result);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> markFollowUpDone(String visitId, {required String outcome}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await remoteDataSource.markFollowUpDone(visitId, outcome: outcome);
      return Right(data);
    } catch (e) {
      return handleException(e);
    }
  }
}
