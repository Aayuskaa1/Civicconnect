import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';

class UpdateReportStatusParams {
  final String reportId;
  final String status;

  const UpdateReportStatusParams({
    required this.reportId,
    required this.status,
  });
}

class UpdateReportStatusUsecase
    implements UsecaseWithParams<ReportEntity, UpdateReportStatusParams> {
  final ReportRepository _repository;

  UpdateReportStatusUsecase(this._repository);

  @override
  Future<Either<Failure, ReportEntity>> call(UpdateReportStatusParams params) {
    return _repository.updateReportStatus(params.reportId, params.status);
  }
}
