import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/contants.dart';

final sharedPrefsProvider = Provider<SharedPrefsProvider>((_) {
  throw UnimplementedError();
});

class SharedPrefsProvider {
  SharedPrefsProvider(this._sharedPrefs);
  final SharedPreferences _sharedPrefs;

  static const _themeKey = "theme";
  static const _lastBackupKey = "last_backup";
  static const _backupTimeKey = "backup_time";
  static const _userConfigKey = USER_CONFIG;
  static const _userProfileKey = USER_PROFILE;
  static const _userPoemKey = USER_POEM;
  static const _userConfigFileKey = "${USER_CONFIG}_file";
  static const _userProfileFileKey = "${USER_PROFILE}_file";
  static const _userPoemFileKey = "${USER_POEM}_file";
  static const _nameKey = "name";
  static const _profileKey = "profile";

  bool get userConfigChange => _sharedPrefs.getBool(_userConfigKey) ?? false;
  set userConfigChange(bool value) {
    _sharedPrefs.setBool(_userConfigKey, value);
  }

  bool get userProfileChange => _sharedPrefs.getBool(_userProfileKey) ?? false;
  set userProfileChange(bool value) {
    _sharedPrefs.setBool(_userProfileKey, value);
  }

  bool get userPoemChange => _sharedPrefs.getBool(_userPoemKey) ?? false;
  set userPoemChange(bool value) {
    _sharedPrefs.setBool(_userPoemKey, value);
  }

  String get theme => _sharedPrefs.getString(_themeKey) ?? "System Default";
  set theme(String theme) {
    _sharedPrefs.setString(_themeKey, theme);
  }

  String? get lastBackupTime => _sharedPrefs.getString(_lastBackupKey);
  set lastBackupTime(String? dateTime) {
    if (dateTime != null) _sharedPrefs.setString(_lastBackupKey, dateTime);
  }

  String? get backupTime => _sharedPrefs.getString(_backupTimeKey);
  set backupTime(String? time) {
    if (time != null) _sharedPrefs.setString(_backupTimeKey, time);
  }

  String? getUserConfigFile() => _sharedPrefs.getString(_userConfigFileKey);
  Future<bool> setUserConfigFile(String value) =>
      _sharedPrefs.setString(_userConfigFileKey, value);

  String? getUserProfileFile() => _sharedPrefs.getString(_userProfileFileKey);
  Future<bool> setUserProfileFile(String value) =>
      _sharedPrefs.setString(_userProfileFileKey, value);

  String? getUserPoemFile() => _sharedPrefs.getString(_userPoemFileKey);
  Future<bool> setUserPoemFile(String value) =>
      _sharedPrefs.setString(_userPoemFileKey, value);

  set name(String? value) {
    if (value == null) return;

    _sharedPrefs.setString(_nameKey, value);
  }

  String? get name => _sharedPrefs.getString(_nameKey);

  set profile(String? value) {
    if (value == null) {
      _sharedPrefs.remove(_profileKey);
      return;
    }
    _sharedPrefs.setString(_profileKey, value);
  }

  String? get profile => _sharedPrefs.getString(_profileKey);
}
