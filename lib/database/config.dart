import 'package:shared_preferences/shared_preferences.dart';

class Config {
  SharedPreferences _sharedPrefs;

  static const String _nameKey = "name";
  static const String _profileKey = "profile";

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  set name(String value) {
    _sharedPrefs.setString(_nameKey, value);
  }

  String get name => _sharedPrefs.getString(_nameKey) ?? "Name";

  set profile(String value) {
    _sharedPrefs.setString(_profileKey, value);
  }

  String get profile => _sharedPrefs.getString(_profileKey);
}
