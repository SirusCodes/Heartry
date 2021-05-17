import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extension/extensions.dart';
import 'shared_prefs_provider.dart';

final backupTimeProvider =
    StateNotifierProvider<BackupTimeProvider, TimeOfDay>((ref) {
  return BackupTimeProvider(ref.watch(sharedPrefsProvider));
});

class BackupTimeProvider extends StateNotifier<TimeOfDay> {
  BackupTimeProvider(this.sharedPrefs) : super(_getBackupTime(sharedPrefs));

  final SharedPrefsProvider sharedPrefs;

  static TimeOfDay _getBackupTime(SharedPrefsProvider sharedPrefs) {
    final storedTime = sharedPrefs.backupTime;
    return storedTime!.parse();
  }

  void setBackupTime(TimeOfDay time) {
    sharedPrefs.backupTime = time.toFormatedString();
    state = time;
  }
}
