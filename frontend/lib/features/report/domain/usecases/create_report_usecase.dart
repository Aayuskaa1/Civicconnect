import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:civic_connect/features/report/domain/repositories/i_report_repository.dart';

class CreateReportUseCase implements UseCase<Either<Failure, ReportEntity>, ReportEntity> {
  final IReportRepository _repository;

  CreateReportUseCase(this._repository);

  @override
  Future<Either<Failure, ReportEntity>> call(ReportEntity params) =>
      _repository.createReport(params);
}
