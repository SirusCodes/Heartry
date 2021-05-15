import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/utils/contants.dart';
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

  bool get isUserConfigChanged {
    return _sharedPrefs.getBool(USER_CONFIG) ?? false;
  }

  bool get isUserProfileChanged {
    return _sharedPrefs.getBool(USER_PROFILE) ?? false;
  }

  bool get isUserPoemChanged {
    return _sharedPrefs.getBool(USER_POEM) ?? false;
  }

  void updateUserConfig({required bool value}) {
    _sharedPrefs.setBool(USER_CONFIG, value);
  }

  void updateUserProfile({required bool value}) {
    _sharedPrefs.setBool(USER_PROFILE, value);
  }

  void updateUserPoem({required bool value}) {
    _sharedPrefs.setBool(USER_POEM, value);
  }
}
