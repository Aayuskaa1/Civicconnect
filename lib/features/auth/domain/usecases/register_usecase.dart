import 'package:civic_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCaseParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String reportId; 
  final String username;
  final String password;

  const RegisterUseCaseParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.reportId,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        reportId,
        username,
        password,
      ];
}

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

class RegisterUseCase implements UsecaseWithParams<bool, RegisterUseCaseParams> {
  final IAuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call(RegisterUseCaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      report: params.reportId, 
      username: params.username,
      password: params.password, userId: '',
    );
    return _authRepository.register(entity);
  }
}