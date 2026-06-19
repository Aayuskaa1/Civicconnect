import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, authenticated, registered, error }

const Object _authStateUnset = Object();

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AuthEntity? user;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    Object? errorMessage = _authStateUnset,
    AuthEntity? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _authStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
      user: user ?? this.user,
    );
  }
}
