import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<Either<Failure, AuthEntity>, LoginParams> {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) =>
      _repository.login(params.email, params.password);
}
