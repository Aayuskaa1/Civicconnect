import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  final SharedPreferences _sharedPrefs;
  static const String _userKey = 'currentUser';

  UserSessionService(this._sharedPrefs);

  Future<void> saveUserSession(String email) async {
    await _sharedPrefs.setString(_userKey, email);
  }

  String? getUserSession() {
    return _sharedPrefs.getString(_userKey);
  }

  Future<void> clearSession() async {
    await _sharedPrefs.remove(_userKey);
  }
}
