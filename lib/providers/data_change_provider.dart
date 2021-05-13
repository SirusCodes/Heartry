import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_provider.dart';

final dataChangeProvider = Provider<DataChangeProvider>((ref) {
  return DataChangeProvider(ref.read);
});

class DataChangeProvider {
  DataChangeProvider(Reader read) : _read = read {
    _sharedPrefs = _read(sharedPrefsProvider);
  }
  final Reader _read;

  late SharedPreferences _sharedPrefs;

  static const _changedUserData = "user_config";
  static const _changedUserPoem = "user_poem";

  bool get isUserConfigChanged {
    return _sharedPrefs.getBool(_changedUserData) ?? false;
  }

  bool get isUserPoemChanged {
    return _sharedPrefs.getBool(_changedUserPoem) ?? false;
  }

  void updateUserData() {
    _sharedPrefs.setBool(_changedUserData, true);
  }

  void updateUserPoem() {
    _sharedPrefs.setBool(_changedUserPoem, true);
  }
}
