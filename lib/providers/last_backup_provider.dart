import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_prefs_provider.dart';

final lastBackupProvider =
    StateNotifierProvider<LastBackupProvider, DateTime?>((ref) {
  return LastBackupProvider(ref.watch(sharedPrefsProvider));
});

class LastBackupProvider extends StateNotifier<DateTime?> {
  LastBackupProvider(SharedPrefsProvider _sharedPrefs)
      : super(_getBackupTime(_sharedPrefs));

  static DateTime? _getBackupTime(SharedPrefsProvider sharedPrefs) {
    final storedTime = sharedPrefs.lastBackupTime;
    return storedTime != null ? DateTime.parse(storedTime) : null;
  }
}
