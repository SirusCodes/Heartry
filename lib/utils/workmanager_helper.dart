import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../database/database.dart';
import '../init_get_it.dart';
import '../providers/backup_restore_manager_provider.dart';

const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'heartry_backup',
      'Backup Notifications',
      importance: Importance.defaultImportance,
      silent: true,
      priority: Priority.defaultPriority,
      icon: "@mipmap/ic_launcher",
    );

const _backupName = "backup-task";
const _backupTask = "backup";

const _deleteBinName = "delete-bin-task";
const _deleteBinTask = "deleteBin";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    initGetIt();
    final sharedprefs = await SharedPreferences.getInstance();
    if (sharedprefs.getBool("hasCompletedOnboarding") != true) {
      return true;
    }

    final container = ProviderContainer();

    if (task == _deleteBinTask) {
      final db = locator<Database>();
      await db.deleteBinAfter30Days();

      // Unregister if bin is empty
      final rows = await db.getBinPoems();
      if (rows.isEmpty) {
        unregisterDeleteBinWorkmanager();
      }

      return true;
    }

    final backupManager = container.read(backupRestoreManagerProvider);
    try {
      final file = await backupManager.createBackupFile();
      final backupHash = await backupManager.getBackupFileHash(file);
      final isSameAsLastBackup = await backupManager.isSameAsLastBackup(
        backupHash,
      );

      if (isSameAsLastBackup) {
        return true;
      }

      final date = await backupManager.backup(file);
      sharedprefs.setString("lastBackup", date.toIso8601String());
      backupManager.setBackupHash(backupHash);

      final dateFomatter = DateFormat.yMMMEd().add_jm();
      FlutterLocalNotificationsPlugin().show(
        0,
        "Your data is safe! 🎉",
        "Backup successful at ${dateFomatter.format(DateTime.now())}",
        const NotificationDetails(android: androidNotificationDetails),
      );
    } catch (e, st) {
      FlutterLocalNotificationsPlugin().show(
        0,
        e.toString(),
        st.toString(),
        const NotificationDetails(android: androidNotificationDetails),
      );

      log("Backup failed: $e", error: e, stackTrace: st);
      return false;
    }
    return true;
  });
}

Future<void> initWorkmanager() async {
  Workmanager().initialize(callbackDispatcher);
}

void registerBackupWorkmanager() {
  final now = DateTime.now();
  final day = now.hour > 2 ? now.day + 1 : now.day;
  final startBackupAt = DateTime(now.year, now.month, day, 2, 0, 0);

  const backupFrequency = Duration(days: 1);

  Workmanager().registerPeriodicTask(
    _backupName,
    _backupTask,
    frequency: backupFrequency,
    initialDelay: startBackupAt.difference(now),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );
}

void unregisterBackupWorkmanager() {
  Workmanager().cancelByUniqueName(_backupName);
}

Future<void> registerDeleteBinWorkmanager() async {
  await Workmanager().registerPeriodicTask(
    _deleteBinName,
    _deleteBinTask,
    frequency: const Duration(days: 1),
    constraints: Constraints(
      requiresBatteryNotLow: true,
      networkType: NetworkType.notRequired,
    ),
  );
}

void unregisterDeleteBinWorkmanager() {
  Workmanager().cancelByUniqueName(_deleteBinName);
}
