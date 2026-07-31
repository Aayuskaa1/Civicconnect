import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthState.initial uses initial status', () {
    final state = AuthState.initial();
    expect(state.status, AuthStatus.initial);
    expect(state.user, isNull);
  });

  test('copyWith updates status and user', () {
    const user = AuthEntity(
      authId: '1',
      email: 'user@test.com',
      fullName: 'User',
    );
    final state = AuthState.initial().copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, user);
  });

  test('copyWith clears error message when null passed', () {
    final state = AuthState.initial().copyWith(
      status: AuthStatus.error,
      errorMessage: 'Failed',
    );
    final cleared = state.copyWith(errorMessage: null);
    expect(cleared.errorMessage, isNull);
  });
}
