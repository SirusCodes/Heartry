import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'backup_manager_provider.dart';

class WorkManagerHandlerProvider {
  WorkManagerHandlerProvider.init(this.read) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    _backupManagerProvider = read(backupManagerProvider);
  }

  final Reader read;
  late BackupManagerProvider _backupManagerProvider;

  void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) {
      switch (taskName) {
        case BackupManagerProvider.key:
          return _backupManagerProvider.run(forced: false);
        default:
          return Future.value(false);
      }
    });
  }
}
