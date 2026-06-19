import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase implements UsecaseWithParams<bool, AuthEntity> {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(AuthEntity params) {
    return _repository.register(params);
  }
}
