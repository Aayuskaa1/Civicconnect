import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _sharedPreferences;

  StorageService(this._sharedPreferences);

  Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}
