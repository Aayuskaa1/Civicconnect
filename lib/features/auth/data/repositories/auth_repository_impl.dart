import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource _authDatasource;

  AuthRepositoryImpl({required IAuthDataSource authDatasource}) : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final result = await _authDatasource.login(email, password);
      return Right(result!.toEntity());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      await _authDatasource.logout(email);
      return const Right(true);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailExists(String email) async {
    try {
      final exists = await _authDatasource.isEmailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}
