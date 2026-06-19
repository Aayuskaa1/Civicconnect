import 'package:civic_connect/core/services/hive/hive_services.dart';
import 'package:civic_connect/features/reports/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/reports/data/models/report_hive_model.dart';

class ReportLocalDatasourceImpl implements ReportLocalDatasource {
  final HiveServices _hiveServices;

  ReportLocalDatasourceImpl(this._hiveServices);

  @override
  Future<void> saveReports(List<ReportHiveModel> reports) async {
    await _hiveServices.saveReports(reports);
  }

  @override
  Future<void> saveReport(ReportHiveModel report) async {
    await _hiveServices.saveReport(report);
  }

  @override
  Future<List<ReportHiveModel>> getReports() async {
    return _hiveServices.getAllReports();
  }

  @override
  Future<List<ReportHiveModel>> getMyReports(String userId) async {
    return _hiveServices.getReportsByUser(userId);
  }

  @override
  Future<ReportHiveModel?> getReportById(String reportId) async {
    return _hiveServices.getReportById(reportId);
  }
}
