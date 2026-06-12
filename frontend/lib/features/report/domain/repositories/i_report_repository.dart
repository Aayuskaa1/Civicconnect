import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';

abstract class IReportRepository {
  Future<Either<Failure, List<ReportEntity>>> getAllReports();
  Future<Either<Failure, ReportEntity>> createReport(ReportEntity entity);
}
