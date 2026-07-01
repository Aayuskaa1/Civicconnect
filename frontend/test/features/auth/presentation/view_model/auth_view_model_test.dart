import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  const tEmail = 'student@test.com';
  const tPassword = 'password123';
  const tFullName = 'Test User';
  const tUser = AuthEntity(
    authId: 'auth-1',
    email: tEmail,
    fullName: tFullName,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => LoginUsecase(mockRepository)),
        registerUsecaseProvider.overrideWith((ref) => RegisterUsecase(mockRepository)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state should be AuthStatus.initial', () {
    final state = container.read(authViewModelProvider);

    expect(state.status, AuthStatus.initial);
    expect(state.errorMessage, isNull);
    expect(state.user, isNull);
  });

  test('register success should update state to registered', () async {
    when(mockRepository.register(any)).thenAnswer((_) async => const Right(true));

    await container.read(authViewModelProvider.notifier).register(
          tFullName,
          tEmail,
          tPassword,
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.registered);
    expect(state.errorMessage, isNull);
    verify(mockRepository.register(any)).called(1);
  });

  test('register error should update state with error message', () async {
    const failure = ApiFailure(message: 'Email already exists');
    when(mockRepository.register(any)).thenAnswer((_) async => const Left(failure));

    await container.read(authViewModelProvider.notifier).register(
          tFullName,
          tEmail,
          tPassword,
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, failure.message);
  });

  test('login success should update state to authenticated with user', () async {
    when(mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tUser));

    await container.read(authViewModelProvider.notifier).login(tEmail, tPassword);

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, tUser);
    expect(state.errorMessage, isNull);
    verify(mockRepository.login(tEmail, tPassword)).called(1);
  });

  test('login error should update state with error message', () async {
    const failure = ApiFailure(message: 'Invalid credentials');
    when(mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(failure));

    await container.read(authViewModelProvider.notifier).login(tEmail, tPassword);

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, failure.message);
    expect(state.user, isNull);
  });
}
