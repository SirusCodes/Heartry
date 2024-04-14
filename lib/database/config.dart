import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/config_model/config_model.dart';
import '../utils/workmanager_helper.dart';

final configProvider =
    AsyncNotifierProvider<Config, ConfigModel>(() => Config());

class Config extends AsyncNotifier<ConfigModel> {
  static late SharedPreferences _sharedPrefs;

  static const String _nameKey = "name";
  static const String _profileKey = "profile";
  static const String _lastBackupKey = "lastBackup";
  static const String _backupEmailKey = "backupEmail";
  static const String _isAutoBackupEnabledKey = "isAutoBackupEnabled";
  static const String _hasCompletedOnboardingKey = "hasCompletedOnboarding";

  set lastBackup(DateTime dateTime) {
    _sharedPrefs.setString(_lastBackupKey, dateTime.toIso8601String());
    state = state.whenData((value) => value.copyWith(lastBackup: dateTime));
  }

  set name(String? value) {
    if (value == null) return;

    _sharedPrefs.setString(_nameKey, value);
    state = state.whenData((data) => data.copyWith(name: value));
  }

  set backupEmail(String? value) {
    if (value == null) {
      _sharedPrefs.remove(_backupEmailKey);
      state = state.whenData((data) => data.removeBackupEmail());

      return;
    }

    _sharedPrefs.setString(_backupEmailKey, value);
    state = state.whenData((data) => data.copyWith(backupEmail: value));
  }

  set isAutoBackupEnabled(bool value) {
    if (value) {
      registerBackupWorkmanager();
    } else {
      unregisterBackupWorkmanager();
    }

    _sharedPrefs.setBool(_isAutoBackupEnabledKey, value);
    state = state.whenData((data) => data.copyWith(isAutoBackupEnabled: value));
  }

  set hasCompletedOnboarding(bool value) {
    _sharedPrefs.setBool(_hasCompletedOnboardingKey, value);
    state = state.whenData(
      (data) => data.copyWith(hasCompletedOnboarding: value),
    );
  }

  set profile(String? value) {
    if (value == null) {
      _sharedPrefs.remove(_profileKey);
      state = state.whenData((data) => data.removeProfile());

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
      backupEmail: _sharedPrefs.getString(_backupEmailKey),
      isAutoBackupEnabled:
          _sharedPrefs.getBool(_isAutoBackupEnabledKey) ?? true,
      hasCompletedOnboarding:
          _sharedPrefs.getBool(_hasCompletedOnboardingKey) ?? false,
      lastBackup: _sharedPrefs.getString(_lastBackupKey) != null
          ? DateTime.parse(_sharedPrefs.getString(_lastBackupKey)!)
          : null,
    );
  }
}
