import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:workmanager/workmanager.dart';

import '../database/config.dart';
import '../database/database.dart';
import '../init_get_it.dart';
import '../models/backup_model.dart';
import '../utils/contants.dart';
import '../utils/google_auth_client.dart';
import 'data_change_provider.dart';
import 'google_sign_in_provider.dart';
import 'shared_prefs_provider.dart';
import 'theme_provider.dart';

final backupManagerProvider = Provider<BackupManagerProvider>((ref) {
  return BackupManagerProvider(ref.read);
});

final _backupDataProvider = Provider<BackupDataProvider>((ref) {
  return BackupDataProvider(ref.read);
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
  BackupManagerProvider(this._read) {
    _bckupDataProvider = _read(_backupDataProvider);
    _dataChangeProvider = _read(dataChangeProvider);
  }

  final Reader _read;

  static const String key = "BackupManagerProvider";

  late BackupDataProvider _bckupDataProvider;
  late DataChangeProvider _dataChangeProvider;

  /// To save user data in google drive drive.
  Future<bool> run() async {
    final authHeaders = await _read(googleSignInProvider.notifier).authHeader;

    debugPrint(authHeaders.toString());

    if (authHeaders == null) return Future.value(false);

    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = DriveApi(authenticateClient);

    bool userConfigResponse = true;
    bool userDataResponse = true;

    if (_dataChangeProvider.isUserConfigChanged) {
      final data = _bckupDataProvider.getUserConfigData();
      userConfigResponse = await _backup(driveApi, USER_CONFIG, data);
    }

    if (_dataChangeProvider.isUserPoemChanged) {
      final data = _bckupDataProvider.getUserPoemData();
      userDataResponse = await _backup(driveApi, USER_POEM, data);
    }

    return userConfigResponse && userDataResponse;
  }

  /// Will backup file on appDataFolder
  Future<bool> _backup(
      DriveApi driveApi, String fileName, Future<List<int>> data) async {
    final Stream<List<int>> mediaStream = data.asStream();
    final media = Media(mediaStream, null, contentType: "application/json");
    final driveFile = File()
      ..name = "$fileName.json"
      ..parents = ["appDataFolder"];

    File? result;
    try {
      result = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        uploadOptions: UploadOptions.resumable,
      );
    } on ApiRequestError {
      return false;
    }

    final updated = await _deleteOldAndUpdateNew(
      driveApi,
      result.id!,
      fileName,
    );

    return updated;
  }

  /// Delete the older file to remove garbage files and
  /// update the ids of new in shared preferences
  Future<bool> _deleteOldAndUpdateNew(
    DriveApi driveApi,
    String newFileId,
    String key,
  ) async {
    final sharedPrefs = _read(sharedPrefsProvider);

    final oldFileId = sharedPrefs.getString(key);

    if (oldFileId != null) {
      try {
        await driveApi.files.delete(oldFileId);
      } on ApiRequestError {
        return false;
      }
    }

    return sharedPrefs.setString(key, newFileId);
  }
}

class BackupDataProvider {
  BackupDataProvider(Reader read) : _read = read;
  final Reader _read;

  Future<List<int>> getUserConfigData() async {
    final config = locator<Config>();
    final theme = _read(themeProvider.notifier).themeString;
    final profileData = config.profile == null
        ? null
        : base64Encode(io.File(config.profile!).readAsBytesSync());

    final backupModel = BackupModel(
      name: config.name,
      theme: theme,
      profile: profileData,
    );

    return backupModel.toJson().codeUnits;
  }

  Future<List<int>> getUserPoemData() async {
    final poems = await locator<Database>().poemsFuture;

    return poems.toString().codeUnits;
  }
}
