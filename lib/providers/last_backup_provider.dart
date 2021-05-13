import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lastBackupProvider =
    StateNotifierProvider<LastBackupProvider, DateTime?>((ref) {
  return LastBackupProvider(ref.watch(sharedPrefsProvider));
});

class LastBackupProvider extends StateNotifier<DateTime?> {
  LastBackupProvider(this.sharedPrefs) : super(_getBackupTime(sharedPrefs));

  final SharedPreferences sharedPrefs;

  static const _backupKey = "last_backup";

  static DateTime? _getBackupTime(SharedPreferences sharedPrefs) {
    final storedTime = sharedPrefs.getString(_backupKey);
    return storedTime != null ? DateTime.parse(storedTime) : null;
  }

  void setLastBackup() {
    final timeNow = DateTime.now();
    sharedPrefs.setString(_backupKey, timeNow.toUtc().toString());

    state = timeNow;
  }
}
