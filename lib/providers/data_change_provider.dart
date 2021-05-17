import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_prefs_provider.dart';

// ignore_for_file: use_setters_to_change_properties

final dataChangeProvider = Provider<DataChangeProvider>((ref) {
  return DataChangeProvider(ref.read);
});

class DataChangeProvider {
  DataChangeProvider(Reader read) : _read = read {
    _sharedPrefs = _read(sharedPrefsProvider);
  }

  final Reader _read;

  late SharedPrefsProvider _sharedPrefs;

  bool get isUserConfigChanged => _sharedPrefs.userConfigChange;

  bool get isUserProfileChanged => _sharedPrefs.userProfileChange;

  bool get isUserPoemChanged => _sharedPrefs.userPoemChange;

  void updateUserConfig({required bool value}) {
    _sharedPrefs.userConfigChange = value;
  }

  void updateUserProfile({required bool value}) {
    _sharedPrefs.userProfileChange = value;
  }

  void updateUserPoem({required bool value}) {
    _sharedPrefs.userPoemChange = value;
  }
}
