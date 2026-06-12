import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isSuccess;
  final AuthEntity? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isSuccess = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    AuthEntity? user,
    String? error,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        user: user ?? this.user,
        error: error,
      );
}
