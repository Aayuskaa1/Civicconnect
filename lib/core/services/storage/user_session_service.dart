import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'username';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyReportId = 'user_report_id'; 
  static const String _keyUserProfileImage = 'user_profile_image';

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    required String phoneNumber,
    required String reportId, 
    String? profileImage,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    await _prefs.setString(_keyReportId, reportId); 

    if (profileImage != null && profileImage.isNotEmpty) {
      await _prefs.setString(_keyUserProfileImage, profileImage);
    }
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyReportId); 
    await _prefs.remove(_keyUserProfileImage);
  }

  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;
  String? getUserId() => _prefs.getString(_keyUserId);
  String? getUserEmail() => _prefs.getString(_keyUserEmail);
  String? getUsername() => _prefs.getString(_keyUsername);
  String? getUserFullName() => _prefs.getString(_keyUserFullName);
  String? getUserPhoneNumber() => _prefs.getString(_keyUserPhoneNumber);
  String? getReportId() => _prefs.getString(_keyReportId); 
  String? getProfileImage() => _prefs.getString(_keyUserProfileImage);
}