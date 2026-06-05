import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';
import 'package:civic_connect/features/complaint/domain/repositories/i_complaint_repository.dart';

class GetComplaintsParams {
  final String userEmail;
  const GetComplaintsParams({required this.userEmail});
}

class GetComplaintsUseCase
    implements UseCase<Either<Failure, List<ComplaintEntity>>, GetComplaintsParams> {
  final IComplaintRepository _repository;

  GetComplaintsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ComplaintEntity>>> call(GetComplaintsParams params) =>
      _repository.getComplaintsByUser(params.userEmail);
}
