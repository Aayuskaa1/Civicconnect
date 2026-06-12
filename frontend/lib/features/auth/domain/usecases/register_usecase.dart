import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';

class RegisterUseCase implements UseCase<Either<Failure, bool>, AuthEntity> {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(AuthEntity params) => _repository.register(params);
}
