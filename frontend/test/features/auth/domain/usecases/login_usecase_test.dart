import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase usecase;

  const tEmail = 'student@test.com';
  const tPassword = 'password123';
  const tParams = LoginParams(email: tEmail, password: tPassword);
  const tUser = AuthEntity(
    authId: 'auth-1',
    email: tEmail,
    fullName: 'Test User',
    role: 'user',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  test('login returns AuthEntity on success', () async {
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tUser));

    final result = await usecase(tParams);

    expect(result, const Right(tUser));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('login returns ApiFailure on invalid credentials', () async {
    const failure = ApiFailure(message: 'Invalid email or password');
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(tParams);

    expect(result, const Left(failure));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
  });

  test('login forwards email and password from LoginParams', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tUser));

    await usecase(const LoginParams(email: 'a@b.com', password: 'secret12'));

    verify(() => mockRepository.login('a@b.com', 'secret12')).called(1);
  });
}
