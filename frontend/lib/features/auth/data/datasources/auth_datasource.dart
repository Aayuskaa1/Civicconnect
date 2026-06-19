import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRemoteDatasource {
  Future<bool> register(AuthEntity entity);
  Future<Map<String, dynamic>> login(String email, String password);
}

abstract class AuthLocalDatasource {
  Future<void> register(AuthHiveModel user);
  Future<void> updateUser(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> isEmailExists(String email);
}
