import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUsecase usecase;

  const tEntity = AuthEntity(
    authId: '',
    email: 'newuser@test.com',
    fullName: 'New User',
    password: 'password123',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  test('should return true when registration is successful', () async {
    when(mockRepository.register(tEntity))
        .thenAnswer((_) async => const Right(true));

    final result = await usecase.call(tEntity);

    expect(result, const Right(true));
    verify(mockRepository.register(tEntity)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ApiFailure when registration fails', () async {
    const failure = ApiFailure(message: 'Email already exists');
    when(mockRepository.register(tEntity))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(tEntity);

    expect(result, const Left(failure));
    verify(mockRepository.register(tEntity)).called(1);
  });
}
