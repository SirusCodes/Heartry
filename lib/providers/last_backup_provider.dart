import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_prefs_provider.dart';

final lastBackupProvider =
    StateNotifierProvider<LastBackupProvider, DateTime?>((ref) {
  return LastBackupProvider(ref.watch(sharedPrefsProvider));
});

class LastBackupProvider extends StateNotifier<DateTime?> {
  LastBackupProvider(this._sharedPrefs) : super(_getBackupTime(_sharedPrefs));

  final SharedPrefsProvider _sharedPrefs;

  static DateTime? _getBackupTime(SharedPrefsProvider sharedPrefs) {
    final storedTime = sharedPrefs.lastBackupTime;
    return storedTime != null ? DateTime.parse(storedTime) : null;
  }

  void setLastBackup() {
    final timeNow = DateTime.now();
    _sharedPrefs.lastBackupTime = timeNow.toUtc().toString();
    state = timeNow;
  }
}
