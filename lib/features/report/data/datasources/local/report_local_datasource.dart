import 'package:civic_connect/features/report/data/datasources/remote/report_datasources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/report/data/models/report_hive_model.dart';

/// Provider to access the local report data source
final reportLocalDatasourceProvider = Provider<ReportLocalDatasource>((ref) { 
  return ReportLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

/// Implementation of the local report data source using Hive
class ReportLocalDatasource implements IReportDatasource {
  final HiveService _hiveService;

  ReportLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<bool> createReport(ReportHiveModel model) async {
    try {
      await _hiveService.createReport(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      await _hiveService.deleteReport(reportId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ReportHiveModel>> getAllReports() async {
    try {
      // Removed 'await' because _hiveService.getAllReports() 
      // returned a List, not a Future.
      return _hiveService.getAllReports();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ReportHiveModel?> getReportById(String reportId) async {
    try {
      // Removed 'await' because _hiveService.getReportById() 
      // returned the model directly, not a Future.
      return _hiveService.getReportById(reportId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateReport(ReportHiveModel model) async {
    try {
      await _hiveService.updateReport(model);
      return true;
    } catch (e) {
      return false;
    }
  }
}