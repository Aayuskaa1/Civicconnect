import 'package:civic_connect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDatasource;

  AuthRepository({required IAuthDataSource authDatasource})
      : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final result = await _authDatasource.login(email, password);
      if (result == null) {
        return Left(LocalDatabaseFailure(message: 'Invalid credentials'));
      }
      return Right(result.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: 'User not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _authDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailExists(String email) async {
    try {
      final exists = await _authDatasource.isEmailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}