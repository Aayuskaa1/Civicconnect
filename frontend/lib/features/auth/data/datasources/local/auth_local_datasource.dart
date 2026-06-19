import 'package:civic_connect/core/services/hive/hive_services.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final HiveServices _hiveServices;

  AuthLocalDatasourceImpl(this._hiveServices);

  @override
  Future<void> register(AuthHiveModel user) async {
    if (_hiveServices.isEmailExists(user.email)) {
      throw Exception('Email already registered');
    }
    await _hiveServices.registerUser(user);
  }

  @override
  Future<void> updateUser(AuthHiveModel user) async {
    await _hiveServices.registerUser(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    final user = await _hiveServices.loginUser(email, password);
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    return user;
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return _hiveServices.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await _hiveServices.logoutUser();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveServices.isEmailExists(email);
  }
}
