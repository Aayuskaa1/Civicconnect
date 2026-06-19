import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _repository.login(params.email, params.password);
  }
}
