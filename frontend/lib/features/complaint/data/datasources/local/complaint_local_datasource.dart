import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/complaint/data/datasources/complaint_datasource.dart';
import 'package:civic_connect/features/complaint/data/models/complaint_hive_model.dart';

class ComplaintLocalDatasource implements IComplaintDataSource {
  final HiveService _hiveService;

  ComplaintLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<List<ComplaintHiveModel>> getAllComplaints() async {
    return _hiveService.getAllComplaints();
  }

  @override
  Future<List<ComplaintHiveModel>> getComplaintsByUser(String userEmail) async {
    return _hiveService.getComplaintsByUser(userEmail);
  }

  @override
  Future<bool> createComplaint(ComplaintHiveModel model) async {
    await _hiveService.createComplaint(model);
    return true;
  }
}
