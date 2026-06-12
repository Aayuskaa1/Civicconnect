import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';
import 'package:civic_connect/features/complaint/domain/repositories/i_complaint_repository.dart';

class CreateComplaintUseCase implements UseCase<Either<Failure, ComplaintEntity>, ComplaintEntity> {
  final IComplaintRepository _repository;

  CreateComplaintUseCase(this._repository);

  @override
  Future<Either<Failure, ComplaintEntity>> call(ComplaintEntity params) =>
      _repository.createComplaint(params);
}
