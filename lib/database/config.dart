import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/models/config_model/config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final configProvider =
    AsyncNotifierProvider<Config, ConfigModel>(() => Config());

class Config extends AsyncNotifier<ConfigModel> {
  static late SharedPreferences _sharedPrefs;

  static const String _nameKey = "name";
  static const String _profileKey = "profile";
  static const String _lastBackupKey = "lastBackup";

  set lastBackup(DateTime? dateTime) {
    _sharedPrefs.setString(_lastBackupKey, dateTime!.toIso8601String());
    state = state.whenData((value) => value.copyWith(lastBackup: dateTime));
  }

  set name(String? value) {
    if (value == null) return;

    _sharedPrefs.setString(_nameKey, value);
    state = state.whenData((data) => data.copyWith(name: value));
  }

  set profile(String? value) {
    if (value == null) {
      _sharedPrefs.remove(_profileKey);
      state = state.whenData((data) => data.copyWith(profile: null));

      return;
    }
    _sharedPrefs.setString(_profileKey, value);
    state = state.whenData((data) => data.copyWith(profile: value));
  }

  @override
  FutureOr<ConfigModel> build() async {
    _sharedPrefs = await SharedPreferences.getInstance();

    return ConfigModel(
      name: _sharedPrefs.getString(_nameKey),
      profile: _sharedPrefs.getString(_profileKey),
      lastBackup: _sharedPrefs.getString(_lastBackupKey) != null
          ? DateTime.parse(_sharedPrefs.getString(_lastBackupKey)!)
          : null,
    );
  }
}
