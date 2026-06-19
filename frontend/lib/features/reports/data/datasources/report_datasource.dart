import 'package:civic_connect/features/reports/data/models/report_hive_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

abstract class ReportRemoteDatasource {
  Future<List<ReportEntity>> getReports();
  Future<List<ReportEntity>> getMyReports(String userId);
  Future<ReportEntity> submitReport(ReportEntity report, String? imagePath);
}

abstract class ReportLocalDatasource {
  Future<void> saveReports(List<ReportHiveModel> reports);
  Future<void> saveReport(ReportHiveModel report);
  Future<List<ReportHiveModel>> getReports();
  Future<List<ReportHiveModel>> getMyReports(String userId);
  Future<ReportHiveModel?> getReportById(String reportId);
}
