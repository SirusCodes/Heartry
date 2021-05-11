import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_provider.dart';

final backupTimeProvider =
    StateNotifierProvider<BackupTimeProvider, TimeOfDay>((ref) {
  return BackupTimeProvider(ref.watch(sharedPrefsProvider));
});

class BackupTimeProvider extends StateNotifier<TimeOfDay> {
  BackupTimeProvider(this.sharedPrefs) : super(_getBackupTime(sharedPrefs));

  final SharedPreferences sharedPrefs;

  static const _backupKey = "backup_time";

  static TimeOfDay _getBackupTime(SharedPreferences sharedPrefs) {
    final storedTime = sharedPrefs.getString(_backupKey);
    return storedTime.parse() ?? const TimeOfDay(hour: 2, minute: 0);
  }

  void setBackupTime(TimeOfDay time) {
    final dateFormat = time.toHmString();

    sharedPrefs.setString(_backupKey, dateFormat);

    state = dateFormat.parse()!;
  }
}

extension FormatTimeOfDay on TimeOfDay {
  String toFormatedString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);
    final String amPm = period == DayPeriod.am ? "AM" : "PM";
    return "$hourLabel:$minuteLabel $amPm";
  }

  String toHmString() {
    return "$hour:$minute";
  }
}

extension FormatTimeOfDayString on String? {
  TimeOfDay? parse() {
    if (this == null) return null;
    final data = this!.split(":").map((e) => int.parse(e)).toList();
    return TimeOfDay(hour: data[0], minute: data[1]);
  }
}
