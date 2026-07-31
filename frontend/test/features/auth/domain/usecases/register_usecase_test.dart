import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUsecase usecase;

  const tUser = AuthEntity(
    authId: '',
    email: 'new@test.com',
    fullName: 'New User',
    password: 'password123',
  );

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        authId: '',
        email: 'fallback@test.com',
        fullName: 'Fallback',
        password: 'password123',
      ),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  test('register returns true on success', () async {
    when(() => mockRepository.register(tUser))
        .thenAnswer((_) async => const Right(true));

    final result = await usecase(tUser);

    expect(result, const Right(true));
    verify(() => mockRepository.register(tUser)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('register returns ApiFailure when email already exists', () async {
    const failure = ApiFailure(message: 'Email already in use');
    when(() => mockRepository.register(tUser))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(tUser);

    expect(result, const Left(failure));
  });

  test('register returns LocalDatabaseFailure on local error', () async {
    const failure = LocalDatabaseFailure('Hive write failed');
    when(() => mockRepository.register(any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(tUser);

    expect(result, const Left(failure));
    verify(() => mockRepository.register(tUser)).called(1);
  });
}
