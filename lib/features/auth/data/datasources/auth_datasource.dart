import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDataSource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<void> logout(String email);
  Future<bool> isEmailExists(String email);
}
