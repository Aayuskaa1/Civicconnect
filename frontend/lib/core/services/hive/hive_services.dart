import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:civic_connect/core/constants/hive_table_constant.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/reports/data/models/report_hive_model.dart';

class HiveServices {
  static const String _sessionBoxName = 'session_box';
  static const String _currentUserKey = 'currentUser';

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReportHiveModelAdapter());
    }

    // Open Boxes
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    await Hive.openBox<ReportHiveModel>(HiveTableConstant.reportBox);
    await Hive.openBox<String>(_sessionBoxName);
  }

  // --- Auth / User Operations ---

  Future<void> registerUser(AuthHiveModel user) async {
    final box = Hive.box<AuthHiveModel>(HiveTableConstant.userBox);
    await box.put(user.email, user);
  }

  AuthHiveModel? getUserByEmail(String email) {
    final box = Hive.box<AuthHiveModel>(HiveTableConstant.userBox);
    return box.get(email);
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final user = getUserByEmail(email);
    if (user != null && user.password == password) {
      final sessionBox = Hive.box<String>(_sessionBoxName);
      await sessionBox.put(_currentUserKey, email);
      return user;
    }
    return null;
  }

  Future<void> logoutUser() async {
    final sessionBox = Hive.box<String>(_sessionBoxName);
    await sessionBox.delete(_currentUserKey);
  }

  AuthHiveModel? getCurrentUser() {
    final sessionBox = Hive.box<String>(_sessionBoxName);
    final email = sessionBox.get(_currentUserKey);
    if (email == null) return null;
    return getUserByEmail(email);
  }

  bool isEmailExists(String email) {
    final box = Hive.box<AuthHiveModel>(HiveTableConstant.userBox);
    return box.containsKey(email);
  }

  // --- Reports Operations ---

  Future<void> saveReport(ReportHiveModel report) async {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    await box.put(report.reportId, report);
  }

  Future<void> saveReports(List<ReportHiveModel> reports) async {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    for (var report in reports) {
      await box.put(report.reportId, report);
    }
  }

  List<ReportHiveModel> getAllReports() {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    final reports = box.values.toList();
    // Sort by createdAt descending
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  List<ReportHiveModel> getReportsByUser(String userId) {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    final reports = box.values.where((r) => r.submittedBy == userId).toList();
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  ReportHiveModel? getReportById(String reportId) {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    return box.get(reportId);
  }

  Future<void> deleteReport(String reportId) async {
    final box = Hive.box<ReportHiveModel>(HiveTableConstant.reportBox);
    await box.delete(reportId);
  }

  Future<void> clearAll() async {
    await Hive.box<AuthHiveModel>(HiveTableConstant.userBox).clear();
    await Hive.box<ReportHiveModel>(HiveTableConstant.reportBox).clear();
    await Hive.box<String>(_sessionBoxName).clear();
  }
}
