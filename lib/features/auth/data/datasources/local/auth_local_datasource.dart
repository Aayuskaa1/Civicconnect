import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/core/services/storage/user_session_service.dart';
import 'package:civic_connect/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';

// Provider definition
final authLocalDatasourceProvider = Provider<IAuthDataSource>((ref) {
  return AuthLocalDatasource(
    hiveService: ref.read(hiveServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  const AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);

      if (user != null) {
        // Removed redundant ?? '' because these fields are already guaranteed 
        // to be non-nullable based on your model definition.
        await _userSessionService.saveUserSession(
          userId: user.authId,
          email: user.email,
          username: user.username,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber ?? '',
          reportId: user.report, 
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // Removed 'await' because getCurrentUser() returns the object directly
      return _hiveService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _userSessionService.clearUserSession();
    _hiveService.close(); // Removed 'await' if close() is synchronous
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      // Removed 'await' if isEmailExists returns the boolean directly
      return _hiveService.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }
}