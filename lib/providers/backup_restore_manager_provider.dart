import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as gapis;
import 'package:heartry/providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/config.dart';
import '../database/database.dart';
import '../init_get_it.dart';
import '../models/backup_model/backup_model.dart';
import 'token_manager.dart';

enum BackupRestoreState {
  idle,
  backingUp,
  restoring,
  success,
  error,
}

final backupManagerProvider =
    StateNotifierProvider<BackupManagerProvider, BackupRestoreState>(
  BackupManagerProvider.new,
);

class BackupManagerProvider extends StateNotifier<BackupRestoreState> {
  BackupManagerProvider(Ref ref)
      : _ref = ref,
        super(BackupRestoreState.idle);

  final Ref _ref;

  Future<void> backup() async {
    state = BackupRestoreState.backingUp;
    try {
      final dateTime = await _ref.read(backupRestoreManagerProvider).backup();
      state = BackupRestoreState.success;
      _ref.read(configProvider.notifier).lastBackup = dateTime;
    } catch (e) {
      state = BackupRestoreState.error;
    }
  }
}

final backupRestoreManagerProvider = Provider<BackupRestoreManagerProvider>(
  (ref) => BackupRestoreManagerProvider(ref),
);

class BackupRestoreManagerProvider {
  const BackupRestoreManagerProvider(this.ref);

  final Ref ref;

  Future<DateTime> backup() async {
    final poems = await locator.get<Database>().getPoems();
    final allPrefs = await _getAllSharedPrefs();

    List<int>? imageBytes;
    if (allPrefs["profile"] != null) {
      imageBytes = io.File(allPrefs["profile"]).readAsBytesSync();
    }
    final backup = BackupModel(
      poems: poems,
      prefs: allPrefs,
      image: imageBytes,
    );

    final data = json.encode(backup);
    final dateTime = DateTime.now().toIso8601String();
    final tempDir = await getTemporaryDirectory();
    final file = io.File('${tempDir.path}/backup-$dateTime.json')
      ..writeAsStringSync(data);

    final drive = await _getDrive();

    await _uploadToDrive(file, drive);
    // await _deleteOldBackups(drive);

    return DateTime.now();
  }

  Future<DateTime> restore() async {
    final downloadedFile = await _downloadFromDrive();

    final data = downloadedFile.readAsStringSync();

    final backup = BackupModel.fromJson(json.decode(data));

    final db = locator.get<Database>();
    final config = ref.read(configProvider.notifier);

    await db.deleteAllPoems();
    await db.insertBatchPoems(backup.poems);

    await _setAllSharedPrefs(backup.prefs);

    if (backup.image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final file = io.File('${appDir.path}/profile.png')
        ..writeAsBytesSync(backup.image!);
      config.profile = file.path;
    } else {
      config.profile = null;
    }

    await downloadedFile.delete();

    ref.invalidate(themeProvider);

    return DateTime.now();
  }

  Future<bool> hasBackup() async {
    final lastestBackupDate = await getLastestBackupDate();

    return lastestBackupDate != null;
  }

  Future<List<(String id, DateTime dateTime)>?> getAllBackups() async {
    final drive = await _getDrive();
    final files = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
      spaces: "appDataFolder",
    );

    return files.files?.map((e) => (e.id!, _getDateFromName(e.name!))).toList();
  }

  removeBackup(String id) async {
    final drive = await _getDrive();
    await drive.files.delete(id);
  }

  Future<DateTime?> getLastestBackupDate() async {
    final drive = await _getDrive();
    final files = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
      spaces: "appDataFolder",
    );
    final backupFiles = files.files;
    if (backupFiles == null || backupFiles.isEmpty) {
      return null;
    }

    return _getDateFromName(backupFiles.first.name!);
  }

  DateTime _getDateFromName(String name) {
    final date = name.split('backup-')[1].split('.json')[0];
    return DateTime.parse(date);
  }

  Future<io.File> _downloadFromDrive() async {
    final drive = await _getDrive();
    final files = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
      spaces: "appDataFolder",
    );
    final backup = files.files?.first;
    if (backup == null) {
      throw BackupRestoreException('No backup found');
    }

    final file = (await drive.files.get(
      backup.id!,
      downloadOptions: gapis.DownloadOptions.fullMedia,
    )) as gapis.Media;

    final tempDir = await getTemporaryDirectory();
    final downloadedFile = io.File('${tempDir.path}/${backup.name}');

    if (downloadedFile.existsSync()) {
      downloadedFile.deleteSync();
    }

    downloadedFile.createSync();

    await file.stream.pipe(downloadedFile.openWrite());
    return downloadedFile;
  }

  Future<gapis.File> _uploadToDrive(
    io.File ioFile,
    gapis.DriveApi drive,
  ) async {
    final file = gapis.File()
      ..name = ioFile.path.split('/').last
      ..copyRequiresWriterPermission = true
      ..createdTime = DateTime.now()
      ..parents = ['appDataFolder'];

    final media = gapis.Media(
      ioFile.openRead(),
      ioFile.lengthSync(),
      contentType: 'application/json',
    );
    final uploadedFile = await drive.files.create(
      file,
      uploadMedia: media,
      enforceSingleParent: true,
    );

    return uploadedFile;
  }

  Future<void> _deleteOldBackups(gapis.DriveApi drive) async {
    final backups = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
      spaces: "appDataFolder",
    );

    final backupFiles = backups.files;
    if (backupFiles == null || backupFiles.isEmpty) {
      return;
    }
    for (int i = 0; i < backupFiles.length; i++) {
      // Don't delete the latest 3 backups
      if (i >= 3) {
        drive.files.delete(backupFiles[i].id!);
      }
    }
  }

  Future<gapis.DriveApi> _getDrive() async {
    final accessToken = await ref.read(tokenManagerProvider).getAccessToken();

    return gapis.DriveApi(GoogleAuthClient(accessToken));
  }

  Future<Map<String, dynamic>> _getAllSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final keys = sharedPrefs.getKeys();
    final prefs = <String, dynamic>{};
    for (final key in keys) {
      prefs[key] = sharedPrefs.get(key);
    }
    return prefs;
  }

  Future<void> _setAllSharedPrefs(Map<String, dynamic> prefs) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    for (final key in prefs.keys) {
      final _ = switch (prefs[key]) {
        int() => sharedPrefs.setInt(key, prefs[key]),
        double() => sharedPrefs.setDouble(key, prefs[key]),
        String() => sharedPrefs.setString(key, prefs[key]),
        bool() => sharedPrefs.setBool(key, prefs[key]),
        List<String>() => sharedPrefs.setStringList(key, prefs[key]),
        _ => throw BackupRestoreException('Unknown type'),
      };
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final _client = http.Client();
  final String accessToken;

  GoogleAuthClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
      'X-Goog-AuthUser': '0',
    });
    return _client.send(request);
  }
}

class BackupRestoreException implements Exception {
  final String message;

  BackupRestoreException(this.message);
}
