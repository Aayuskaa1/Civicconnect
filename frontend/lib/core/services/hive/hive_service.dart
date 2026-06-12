import 'package:hive_flutter/hive_flutter.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/report/data/models/report_hive_model.dart';
import 'package:civic_connect/features/complaint/data/models/complaint_hive_model.dart';

class HiveService {
  static const String _authBox = 'auth_box';
  static const String _reportBox = 'report_box';
  static const String _complaintBox = 'complaint_box';
  static const String _sessionKey = 'current_session';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AuthHiveModelAdapter());
    Hive.registerAdapter(ReportHiveModelAdapter());
    Hive.registerAdapter(ComplaintHiveModelAdapter());
    await Hive.openBox<AuthHiveModel>(_authBox);
    await Hive.openBox<ReportHiveModel>(_reportBox);
    await Hive.openBox<ComplaintHiveModel>(_complaintBox);
    await Hive.openBox<String>('session_box');
  }

  Box<AuthHiveModel> get _authHiveBox => Hive.box<AuthHiveModel>(_authBox);
  Box<ReportHiveModel> get _reportHiveBox => Hive.box<ReportHiveModel>(_reportBox);
  Box<ComplaintHiveModel> get _complaintHiveBox => Hive.box<ComplaintHiveModel>(_complaintBox);
  Box<String> get _sessionBox => Hive.box<String>('session_box');

  // --- Auth Operations ---
  Future<void> registerUser(AuthHiveModel user) async => await _authHiveBox.put(user.email, user);

  AuthHiveModel? getUser(String email) => _authHiveBox.get(email);

  Future<void> deleteUser(String email) async => await _authHiveBox.delete(email);

  List<AuthHiveModel> getAllUsers() => _authHiveBox.values.toList();

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final user = _authHiveBox.get(email);
    if (user != null && user.password == password) {
      await _sessionBox.put(_sessionKey, email);
      return user;
    }
    return null;
  }

  Future<void> clearSession() async {
    await _sessionBox.delete(_sessionKey);
    await _sessionBox.delete('token');
  }

  Future<void> setCurrentSession(String email) async => await _sessionBox.put(_sessionKey, email);

  Future<void> saveToken(String token) async => await _sessionBox.put('token', token);

  String? getToken() => _sessionBox.get('token');

  String? getCurrentSessionEmail() => _sessionBox.get(_sessionKey);

  AuthHiveModel? getCurrentUser() {
    final email = getCurrentSessionEmail();
    if (email == null) return null;
    return _authHiveBox.get(email);
  }

  bool isEmailExists(String email) => _authHiveBox.containsKey(email);

  // --- Report Operations ---
  Future<void> createReport(ReportHiveModel model) async =>
      await _reportHiveBox.put(model.reportId, model);

  ReportHiveModel? getReportById(String reportId) => _reportHiveBox.get(reportId);

  List<ReportHiveModel> getAllReports() => _reportHiveBox.values.toList();

  Future<void> updateReport(ReportHiveModel model) async =>
      await _reportHiveBox.put(model.reportId, model);

  Future<void> deleteReport(String reportId) async => await _reportHiveBox.delete(reportId);

  // --- Complaint Operations ---
  Future<void> createComplaint(ComplaintHiveModel model) async =>
      await _complaintHiveBox.put(model.complaintId, model);

  ComplaintHiveModel? getComplaintById(String complaintId) =>
      _complaintHiveBox.get(complaintId);

  List<ComplaintHiveModel> getAllComplaints() => _complaintHiveBox.values.toList();

  List<ComplaintHiveModel> getComplaintsByUser(String userEmail) =>
      _complaintHiveBox.values.where((c) => c.userEmail == userEmail).toList();

  Future<void> updateComplaint(ComplaintHiveModel model) async =>
      await _complaintHiveBox.put(model.complaintId, model);

  Future<void> deleteComplaint(String complaintId) async =>
      await _complaintHiveBox.delete(complaintId);
}
