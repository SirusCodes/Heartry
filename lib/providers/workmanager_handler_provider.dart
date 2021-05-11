import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:workmanager/workmanager.dart';

import '../utils/google_auth_client.dart';
import 'google_sign_in_provider.dart';

final backupManagerProvider = Provider<BackupManagerProvider>((ref) {
  return BackupManagerProvider(ref.read);
});

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
          return _backupManagerProvider.run();
        default:
          return Future.value(false);
      }
    });
  }
}

class BackupManagerProvider {
  BackupManagerProvider(this._read);

  final Reader _read;

  static const String key = "BackupManagerProvider";

  /// To save user data in google drive drive.
  Future<bool> run() async {
    final authHeaders = await _read(googleSignInProvider.notifier).authHeader;

    if (authHeaders == null) return Future.value(false);

    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = DriveApi(authenticateClient);

    final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    final media = Media(mediaStream, 2);
    final driveFile = File()
      ..name = "backup.json"
      ..parents = ["appDataFolder"];

    final result = await driveApi.files.create(driveFile, uploadMedia: media);

    return result.isAppAuthorized != null && result.isAppAuthorized!;
  }
}
