import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/core/services/hive/hive_services.dart';
import 'package:civic_connect/core/services/connectivity/network_info.dart';
import 'package:civic_connect/core/services/storage/token_service.dart';
import 'package:civic_connect/core/services/storage/user_session_service.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:civic_connect/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:civic_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';

// Dependency Providers
final hiveServicesProvider = Provider<HiveServices>((ref) => HiveServices());
final dioProvider = Provider<Dio>((ref) => Dio());
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(ref.read(secureStorageProvider));
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final sharedPrefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(sharedPrefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider), ref.read(tokenServiceProvider));
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.read(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasourceImpl(ref.read(hiveServicesProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    tokenService: ref.read(tokenServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.read(authRepositoryProvider));
});

// ViewModel NotifierProvider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> register(String fullName, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    final entity = AuthEntity(
      authId: '',
      email: email,
      fullName: fullName,
      password: password,
    );
    final result = await ref.read(registerUsecaseProvider).call(entity);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginParams(email: email, password: password);
    final result = await ref.read(loginUsecaseProvider).call(params);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> updateProfilePicture(String imagePath) async {
    final user = state.user;
    if (user == null) return;

    await updateProfile(fullName: user.fullName, imagePath: imagePath);
  }

  Future<void> updateProfile({
    required String fullName,
    String? imagePath,
  }) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No authenticated user found',
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      user: user,
    );

    try {
      final sanitizedName = fullName.trim();
      final resolvedName = sanitizedName.isEmpty
          ? user.fullName
          : sanitizedName;
      String? resolvedProfilePicture = user.profilePicture;

      if (imagePath != null && imagePath.trim().isNotEmpty) {
        final isOnline = await ref.read(networkInfoProvider).isConnected;
        if (isOnline) {
          try {
            final response = await ref
                .read(apiClientProvider)
                .uploadFile(ApiEndpoints.profilePicture, imagePath);
            if (response.statusCode == 200) {
              resolvedProfilePicture =
                  response.data['data']['url'] as String? ?? imagePath;
            } else {
              resolvedProfilePicture = imagePath;
            }
          } catch (_) {
            resolvedProfilePicture = imagePath;
          }
        } else {
          resolvedProfilePicture = imagePath;
        }
      }

      final updatedUser = AuthEntity(
        authId: user.authId,
        email: user.email,
        fullName: resolvedName,
        password: user.password,
        profilePicture: resolvedProfilePicture,
        role: user.role,
      );

      final hiveModel = AuthHiveModel.fromEntity(updatedUser);
      await ref.read(authLocalDataSourceProvider).updateUser(hiveModel);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: null,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        user: user,
      );
    }
  }

  Future<bool> checkAutoLogin() async {
    try {
      final token = await ref.read(tokenServiceProvider).getToken();
      if (token != null) {
        final localUser = await ref
            .read(authLocalDataSourceProvider)
            .getCurrentUser();
        if (localUser != null) {
          final entity = localUser.toEntity();
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: entity,
          );
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await ref.read(tokenServiceProvider).clearToken();
    await ref.read(userSessionServiceProvider).clearSession();
    await ref.read(hiveServicesProvider).logoutUser();
    state = AuthState.initial();
  }

  void resetState() {
    state = AuthState.initial();
  }
}
