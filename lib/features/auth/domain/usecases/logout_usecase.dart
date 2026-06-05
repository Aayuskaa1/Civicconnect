import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/repositories/i_auth_repository.dart';

class LogoutUseCase implements UseCase<Either<Failure, bool>, String> {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(String params) => _repository.logout(params);
}
