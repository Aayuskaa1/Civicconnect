import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';

class SubmitReportParams {
  final ReportEntity report;
  final String? imagePath;

  const SubmitReportParams({required this.report, this.imagePath});
}

class SubmitReportUsecase implements UsecaseWithParams<ReportEntity, SubmitReportParams> {
  final ReportRepository _repository;

  SubmitReportUsecase(this._repository);

  @override
  Future<Either<Failure, ReportEntity>> call(SubmitReportParams params) {
    return _repository.submitReport(params.report, params.imagePath);
  }
}
