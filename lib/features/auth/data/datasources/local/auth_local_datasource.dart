import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  const AuthLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel model) async {
    if (_hiveService.isEmailExists(model.email)) {
      throw Exception('Email already registered');
    }
    await _hiveService.registerUser(model);
    return true;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    final user = await _hiveService.loginUser(email, password);
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    return user;
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    final user = _hiveService.getCurrentUser();
    if (user == null) {
      throw Exception('No active session');
    }
    return user;
  }

  @override
  Future<void> logout(String email) async {
    await _hiveService.clearSession();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailExists(email);
  }
}
