import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:civic_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(authDatasource: ref.read(authLocalDatasourceProvider));
});

final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final loginUsecaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final authViewModelProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    registerUsecase: ref.read(registerUsecaseProvider),
    loginUsecase: ref.read(loginUsecaseProvider),
    logoutUsecase: ref.read(logoutUsecaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUsecase;
  final LoginUseCase _loginUsecase;
  final LogoutUseCase _logoutUsecase;

  AuthNotifier({
    required RegisterUseCase registerUsecase,
    required LoginUseCase loginUsecase,
    required LogoutUseCase logoutUsecase,
  })  : _registerUsecase = registerUsecase,
        _loginUsecase = loginUsecase,
        _logoutUsecase = logoutUsecase,
        super(const AuthState());

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await _registerUsecase(entity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await _loginUsecase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, isSuccess: true, user: user),
    );
  }

  Future<void> logout(String email) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await _logoutUsecase(email);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
  }

  void resetState() => state = const AuthState();
}
