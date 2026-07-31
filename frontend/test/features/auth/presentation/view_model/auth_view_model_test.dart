import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        authId: 'fallback',
        email: 'fallback@test.com',
        fullName: 'Fallback',
      ),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => LoginUsecase(mockRepository)),
        registerUsecaseProvider
            .overrideWith((ref) => RegisterUsecase(mockRepository)),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('register sets registered status on success', () async {
    when(() => mockRepository.register(any()))
        .thenAnswer((_) async => const Right(true));

    await container.read(authViewModelProvider.notifier).register(
          'Test User',
          'user@test.com',
          'password123',
        );

    expect(container.read(authViewModelProvider).status, AuthStatus.registered);
  });

  test('register sets error status on failure', () async {
    when(() => mockRepository.register(any())).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Email already exists')),
    );

    await container.read(authViewModelProvider.notifier).register(
          'Test User',
          'taken@test.com',
          'password123',
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Email already exists');
  });

  test('login sets authenticated status on success', () async {
    const user = AuthEntity(
      authId: 'auth-1',
      email: 'user@test.com',
      fullName: 'Test User',
    );
    when(() => mockRepository.login('user@test.com', 'password123'))
        .thenAnswer((_) async => const Right(user));

    await container.read(authViewModelProvider.notifier).login(
          'user@test.com',
          'password123',
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, user);
  });

  test('login sets error status on invalid credentials', () async {
    when(() => mockRepository.login(any(), any())).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Invalid email or password')),
    );

    await container.read(authViewModelProvider.notifier).login(
          'user@test.com',
          'wrong',
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Invalid email or password');
  });

  test('resetState clears error while keeping authenticated user', () async {
    const user = AuthEntity(
      authId: 'auth-1',
      email: 'user@test.com',
      fullName: 'Test User',
    );
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(user));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.login('user@test.com', 'password123');
    notifier.resetState();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.errorMessage, isNull);
    expect(state.user, user);
  });
}
