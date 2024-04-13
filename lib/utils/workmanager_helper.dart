// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:heartry/providers/backup_restore_manager_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../init_get_it.dart';

const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
  'your_channel_id',
  'Random channel',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  icon: "@mipmap/ic_launcher",
);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    initGetIt();
    final sharedprefs = await SharedPreferences.getInstance();
    sharedprefs.setString("workmanger-running", "yes");
    final container = ProviderContainer();
    final backupManager = container.read(backupRestoreManagerProvider);
    try {
      await backupManager.backup();
      sharedprefs.setString("backup", "pass");
    } catch (e, st) {
      FlutterLocalNotificationsPlugin().show(
        0,
        e.toString(),
        st.toString(),
        const NotificationDetails(android: androidNotificationDetails),
      );

      log("Backup failed: $e", error: e, stackTrace: st);
      sharedprefs.setString("backup", "$e ${'-' * 25} $st");
      return false;
    }
    return true;
  });
}

Future<void> initWorkmanager() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  print("Backup status: ");
  print(sharedPrefs.getString("backup") ?? "null");
  print(sharedPrefs.getString("workmanger-running") ?? "not running");

  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
}

void registerBackupWorkmanager() {
  Workmanager().registerPeriodicTask(
    "backup-task",
    "backup",
    frequency: const Duration(minutes: 2),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );
}

void unregisterBackupWorkmanager() {
  Workmanager().cancelByUniqueName("backup-task");
}
