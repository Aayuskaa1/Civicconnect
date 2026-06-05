import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:civic_connect/core/constants/hive_table_constant.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/report/data/models/report_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _registerAdapter();
    await openBoxes();
  }

  // Register Adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HelpDeskTableConstant.reportTypeId)) {
      Hive.registerAdapter(ReportHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HelpDeskTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<ReportHiveModel>(HelpDeskTableConstant.reportTable);
    await Hive.openBox<AuthHiveModel>(HelpDeskTableConstant.userTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  // --- Report Operations ---
  Box<ReportHiveModel> get _reportBox =>
      Hive.box<ReportHiveModel>(HelpDeskTableConstant.reportTable);

  Future<void> createReport(ReportHiveModel model) async {
    await _reportBox.put(model.reportId, model);
  }

  // ADDED: Missing method needed by your DataSource
  ReportHiveModel? getReportById(String reportId) {
    return _reportBox.get(reportId);
  }

  List<ReportHiveModel> getAllReports() {
    return _reportBox.values.toList();
  }

  Future<void> updateReport(ReportHiveModel model) async {
    await _reportBox.put(model.reportId, model);
  }

  Future<void> deleteReport(String reportId) async {
    await _reportBox.delete(reportId);
  }

  // --- Auth Operations ---
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HelpDeskTableConstant.userTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // UPDATED: Included password check for security
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<void> logoutUser(String authId) async {
    await _authBox.delete(authId);
  }

  Future<bool> isEmailExists(String email) async {
    return _authBox.values.any((user) => user.email == email);
  }

  AuthHiveModel? getCurrentUser() {
    final users = _authBox.values;
    return users.isNotEmpty ? users.first : null;
  }
}