import 'package:civic_connect/features/report/data/models/report_hive_model.dart';

abstract class IReportDataSource {
  Future<List<ReportHiveModel>> getAllReports();
  Future<ReportHiveModel?> getReportById(String reportId);
  Future<bool> createReport(ReportHiveModel model);
  Future<bool> updateReport(ReportHiveModel model);
  Future<bool> deleteReport(String reportId);
}
