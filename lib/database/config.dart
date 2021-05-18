import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shared_prefs_provider.dart';

final configProvider = ChangeNotifierProvider<Config>(
    (ref) => Config(ref.read(sharedPrefsProvider)));

class Config extends ChangeNotifier {
  Config(SharedPrefsProvider sharedPrefs) : _sharedPrefs = sharedPrefs;
  final SharedPrefsProvider _sharedPrefs;

  set name(String? value) {
    _sharedPrefs.name = value;
    notifyListeners();
  }

  String? get name => _sharedPrefs.name;

  set profile(String? value) {
    _sharedPrefs.profile = value;
    notifyListeners();
  }

  String? get profile => _sharedPrefs.profile;
}
