import 'dart:io' as io;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mime_type/mime_type.dart' as m;
import 'package:path/path.dart' as p;

import '../database/config.dart';
import '../database/database.dart';
import '../init_get_it.dart';
import '../models/backup_model.dart';
import '../utils/contants.dart';
import '../utils/google_auth_client.dart';
import 'data_change_provider.dart';
import 'google_sign_in_provider.dart';
import 'shared_prefs_provider.dart';

final backupManagerProvider = Provider<BackupManagerProvider>((ref) {
  return BackupManagerProvider(ref.read);
});

class BackupManagerProvider {
  BackupManagerProvider(this._read) {
    _dataChangeProvider = _read(dataChangeProvider);
  }

  final Reader _read;

  static const String key = "BackupManagerProvider";

  late DataChangeProvider _dataChangeProvider;

  /// To save user data in google drive drive.
  Future<bool> run() async {
    final authHeaders = await _read(googleSignInProvider.notifier).authHeader;

    if (authHeaders == null) return Future.value(false);

    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = DriveApi(authenticateClient);

    final sharedPrefs = _read(sharedPrefsProvider);
    final theme = sharedPrefs.theme;

    final backupConfig = BackupConfig(
      driveApi,
      sharedPrefs,
      theme,
      _dataChangeProvider,
    );

    final backupProfile = BackupProfile(
      driveApi,
      sharedPrefs,
      _dataChangeProvider,
    );

    final backupPoems = BackupPoem(driveApi, sharedPrefs, _dataChangeProvider);

    final backups = [backupConfig, backupProfile, backupPoems];

    final List<Future<bool>> backupResultsFuture = [];
    for (final backup in backups) {
      backupResultsFuture.add(backup.startBackup());
    }

    final List<bool> backupResults = await Future.wait(backupResultsFuture);

    return backupResults.fold<bool>(
      true,
      (previousValue, element) => previousValue && element,
    );
  }
}

abstract class BackupData {
  BackupData(this.driveApi, this.sharedPrefs);

  /// should return the data to store in drive
  Future<List<int>?> get data;

  /// File name with extension (filename.json)
  String get fileName;

  /// if there is a change in the data
  bool get isChanged;

  /// old drive file id
  String? get oldId;

  /// Content type of the file defaults to ["application/json"]
  String get contentType => "application/json";

  final DriveApi driveApi;
  final SharedPrefsProvider sharedPrefs;

  /// To update the status of change i.e. after backup change should false to
  /// stop from updating forever
  void updateSharedPref();

  /// will return new saved Id
  Future<bool> updateNewId(String newId);

  /// Check if the needs to backup if yes then start of else
  /// return true;
  Future<bool> startBackup() async {
    if (!isChanged) return true;
    final isBackupSuccess = await _backup();
    updateSharedPref();
    return isBackupSuccess;
  }

  /// Will backup file on appDataFolder
  Future<bool> _backup() async {
    final backup = await data;
    if (backup == null) return true;
    final Stream<List<int>> mediaStream = Stream.value(backup);
    final media = Media(mediaStream, null, contentType: contentType);
    final driveFile = File()
      ..name = fileName
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

    final updated = await _deleteOldAndUpdateNew(result.id!);

    return updated;
  }

  /// Delete the older file to remove garbage files and
  /// update the ids of new in shared preferences
  Future<bool> _deleteOldAndUpdateNew(String newFileId) async {
    final oldFileId = oldId;
    if (oldFileId != null) {
      try {
        await driveApi.files.delete(oldFileId);
      } on ApiRequestError {
        return false;
      }
    }

    return updateNewId(newFileId);
  }
}

class BackupConfig extends BackupData {
  BackupConfig(
    DriveApi driveApi,
    SharedPrefsProvider sharedPrefs,
    this.theme,
    this.dataChangeProvider,
  ) : super(driveApi, sharedPrefs);

  final String theme;
  final DataChangeProvider dataChangeProvider;

  @override
  Future<List<int>?> get data async {
    final config = locator<Config>();
    final backupModel = BackupModel(
      name: config.name,
      theme: theme,
    );
    return backupModel.toJson().codeUnits;
  }

  @override
  String get fileName => "$USER_CONFIG.json";

  @override
  bool get isChanged => dataChangeProvider.isUserConfigChanged || true;

  @override
  void updateSharedPref() => dataChangeProvider.updateUserConfig(value: false);

  @override
  String? get oldId => sharedPrefs.getUserConfigFile();

  @override
  Future<bool> updateNewId(String newId) =>
      sharedPrefs.setUserConfigFile(newId);
}

class BackupProfile extends BackupData {
  BackupProfile(
    DriveApi driveApi,
    SharedPrefsProvider sharedPrefs,
    this.dataChangeProvider,
  ) : super(driveApi, sharedPrefs);

  late String _contentType, _fileName;
  final DataChangeProvider dataChangeProvider;

  @override
  Future<List<int>?> get data async {
    final profile = locator<Config>().profile;
    if (profile == null) return null;
    final file = io.File(profile);
    final extension = p.extension(file.path);
    _fileName = "profile$extension";
    _contentType = m.mime(file.path) ?? "image/*";
    final fileData = await file.readAsBytes();
    return fileData.toList(growable: false);
  }

  @override
  String get fileName => _fileName;

  @override
  String get contentType => _contentType;

  @override
  bool get isChanged => dataChangeProvider.isUserProfileChanged || true;

  @override
  void updateSharedPref() => dataChangeProvider.updateUserProfile(value: false);

  @override
  String? get oldId => sharedPrefs.getUserProfileFile();

  @override
  Future<bool> updateNewId(String newId) =>
      sharedPrefs.setUserProfileFile(newId);
}

class BackupPoem extends BackupData {
  BackupPoem(
    DriveApi driveApi,
    SharedPrefsProvider sharedPrefs,
    this.dataChangeProvider,
  ) : super(driveApi, sharedPrefs);

  final DataChangeProvider dataChangeProvider;

  @override
  Future<List<int>?> get data async {
    final poems = await locator<Database>().poemsFuture;
    return poems.toString().codeUnits;
  }

  @override
  String get fileName => "$USER_POEM.json";

  @override
  bool get isChanged => dataChangeProvider.isUserPoemChanged || true;

  @override
  void updateSharedPref() => dataChangeProvider.updateUserPoem(value: false);

  @override
  String? get oldId => sharedPrefs.getUserPoemFile();

  @override
  Future<bool> updateNewId(String newId) => sharedPrefs.setUserPoemFile(newId);
}
