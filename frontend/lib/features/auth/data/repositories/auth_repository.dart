import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/services/connectivity/network_info.dart';
import 'package:civic_connect/core/services/storage/token_service.dart';
import 'package:civic_connect/core/services/storage/user_session_service.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_api_model.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDataSource;
  final AuthLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;
  final TokenService _tokenService;
  final UserSessionService _userSessionService;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDataSource,
    required AuthLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
    required TokenService tokenService,
    required UserSessionService userSessionService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _tokenService = tokenService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final success = await _remoteDataSource.register(entity);
        if (success) {
          // Cache locally as well
          final hiveModel = AuthHiveModel.fromEntity(entity);
          await _localDataSource.register(hiveModel);
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Registration failed'));
      } else {
        // Offline registration in Hive
        final hiveModel = AuthHiveModel.fromEntity(entity);
        await _localDataSource.register(hiveModel);
        return const Right(true);
      }
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        try {
          final responseMap = await _remoteDataSource.login(email, password);
          final dataMap = responseMap['data'] as Map<String, dynamic>;
          final token = dataMap['token'] as String;
          final userData = dataMap['user'] as Map<String, dynamic>;

          final apiModel = AuthApiModel.fromJson(userData);
          final entity = AuthEntity(
            authId: apiModel.id,
            email: apiModel.email,
            fullName: '${apiModel.firstName} ${apiModel.lastName}'.trim(),
            username: apiModel.username,
            password:
                password, // cache password locally for offline login capability
            role: apiModel.role ?? 'user',
            profilePicture: apiModel.profilePicture,
          );

          // Save token & session
          await _tokenService.saveToken(token);
          await _userSessionService.saveUserSession(entity.email);

          // Cache in Hive
          final hiveModel = AuthHiveModel.fromEntity(entity);
          // Check if user already exists in Hive. If so, overwrite/update, else register
          final exists = await _localDataSource.isEmailExists(entity.email);
          if (exists) {
            await _localDataSource.updateUser(hiveModel);
          } else {
            await _localDataSource.register(hiveModel);
          }

          return Right(entity);
        } catch (remoteError) {
          // If remote fails, fallback to cached login if user exists locally
          try {
            final localUser = await _localDataSource.login(email, password);
            if (localUser != null) {
              final entity = localUser.toEntity();
              await _userSessionService.saveUserSession(entity.email);
              return Right(entity);
            }
          } catch (_) {}
          return Left(
            ApiFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      } else {
        // Offline: try local login
        final localUser = await _localDataSource.login(email, password);
        if (localUser != null) {
          final entity = localUser.toEntity();
          await _userSessionService.saveUserSession(entity.email);
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(
            'User not found or invalid password in local DB',
          ),
        );
      }
    } catch (e) {
      return Left(
        LocalDatabaseFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
