import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/report/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/report/data/models/report_hive_model.dart';

class ReportLocalDatasource implements IReportDataSource {
  final HiveService _hiveService;

  ReportLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<List<ReportHiveModel>> getAllReports() async {
    return _hiveService.getAllReports();
  }

  @override
  Future<ReportHiveModel?> getReportById(String reportId) async {
    return _hiveService.getReportById(reportId);
  }

  @override
  Future<bool> createReport(ReportHiveModel model) async {
    await _hiveService.createReport(model);
    return true;
  }

  @override
  Future<bool> updateReport(ReportHiveModel model) async {
    await _hiveService.updateReport(model);
    return true;
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    await _hiveService.deleteReport(reportId);
    return true;
  }
}
