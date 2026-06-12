import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:civic_connect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDatasource _authLocalDatasource;
  final HiveService _hiveService;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource authRemoteDataSource,
    required AuthLocalDatasource authLocalDatasource,
    required HiveService hiveService,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _authLocalDatasource = authLocalDatasource,
        _hiveService = hiveService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final success = await _authRemoteDataSource.register(entity);
      return Right(success);
    } catch (e) {
      return Left(ApiFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final responseMap = await _authRemoteDataSource.login(email, password);
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      final token = dataMap['token'] as String;
      final userData = dataMap['user'] as Map<String, dynamic>;

      // Map dynamic JSON from API response to AuthEntity
      final entity = AuthEntity(
        userId: userData['_id'] as String,
        fullName: '${userData['firstName']} ${userData['lastName']}'.trim(),
        email: userData['email'] as String,
        phoneNumber: userData['phoneNumber'] as String?,
        userRole: userData['role'] as String? ?? 'Citizen',
        username: userData['username'] as String,
        profilePicture: userData['profilePicture'] as String?,
        department: userData['department'] as String? ?? 'General',
        password: '', // Password is not returned by API
        report: userData['report'] as String? ?? '',
      );

      // Cache the JWT token in secure storage and Hive
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'auth_token', value: token);
      await _hiveService.saveToken(token);

      // Cache the user info locally in Hive
      final model = AuthHiveModel.fromEntity(entity);
      await _hiveService.registerUser(model);
      await _hiveService.setCurrentSession(entity.email);

      return Right(entity);
    } catch (e) {
      return Left(ApiFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      await _hiveService.clearSession();
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'auth_token');
      return const Right(true);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailExists(String email) async {
    try {
      final exists = await _authLocalDatasource.isEmailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}
