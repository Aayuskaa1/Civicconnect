import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<ReportEntity>>> getReports();
  Future<Either<Failure, List<ReportEntity>>> getMyReports(String userId);
  Future<Either<Failure, ReportEntity>> submitReport(ReportEntity report, String? imagePath);
  Future<Either<Failure, ReportEntity>> updateReportStatus(String reportId, String status);
}
