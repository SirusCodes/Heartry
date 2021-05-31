import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

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

  Future<void> setProfile(String filePath, List<int> imageData) async {
    final fileName = p.basename(filePath);
    await _sharedPrefs.setProfile(fileName, imageData);
    notifyListeners();
  }

  Future<void> removeProfile() async {
    _sharedPrefs.removeProfile();
    notifyListeners();
  }

  String? get profile => _sharedPrefs.profile;
}
