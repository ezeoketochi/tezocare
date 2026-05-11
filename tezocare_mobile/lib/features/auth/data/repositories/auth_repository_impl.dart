import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Token>> login(String email, String password) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tokenModel = await remoteDataSource.login(email, password);
      return Right(tokenModel);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Staff>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final staffModel = await remoteDataSource.getCurrentUser();
      return Right(staffModel);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, Token>> refreshToken(String refreshToken) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tokenModel = await remoteDataSource.refreshToken(refreshToken);
      return Right(tokenModel);
    } catch (e) {
      return handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return handleException(e);
    }
  }
}
