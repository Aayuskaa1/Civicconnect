import 'package:civic_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUseCaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Provider for LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

class LoginUseCase implements UsecaseWithParams<AuthEntity, LoginUseCaseParams> {
  final IAuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUseCaseParams params) async {
    // Directly calling the repository method
    return await _authRepository.login(params.email, params.password);
  }
}