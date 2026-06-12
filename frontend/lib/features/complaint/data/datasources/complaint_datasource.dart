import 'package:civic_connect/features/complaint/data/models/complaint_hive_model.dart';

abstract class IComplaintDataSource {
  Future<List<ComplaintHiveModel>> getAllComplaints();
  Future<List<ComplaintHiveModel>> getComplaintsByUser(String userEmail);
  Future<bool> createComplaint(ComplaintHiveModel model);
}
