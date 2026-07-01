import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

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
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  test('should return AuthEntity when login is successful', () async {
    when(mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tUser));

    final result = await usecase.call(tParams);

    expect(result, const Right(tUser));
    verify(mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ApiFailure when login fails', () async {
    const failure = ApiFailure(message: 'Invalid email or password');
    when(mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(tParams);

    expect(result, const Left(failure));
    verify(mockRepository.login(tEmail, tPassword)).called(1);
  });
}
