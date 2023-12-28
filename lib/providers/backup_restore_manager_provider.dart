import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../database/config.dart';
import '../database/database.dart';
import '../init_get_it.dart';
import '../models/backup_model/backup_model.dart';
import 'auth_provider.dart';
import 'theme_provider.dart';

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

final restoreManagerProvider =
    StateNotifierProvider<RestoreManagerProvider, BackupRestoreState>(
  RestoreManagerProvider.new,
);

class RestoreManagerProvider extends StateNotifier<BackupRestoreState> {
  RestoreManagerProvider(Ref ref)
      : _ref = ref,
        super(BackupRestoreState.idle);

  final Ref _ref;

  Future<void> restore() async {
    state = BackupRestoreState.restoring;
    try {
      final dateTime = await _ref.read(backupRestoreManagerProvider).restore();
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
    final config = ref.read(configProvider);
    final theme = ref.read(themeProvider.notifier).getThemeDetails();

    List<int>? imageBytes;
    if (config.profile != null) {
      imageBytes = io.File(config.profile!).readAsBytesSync();
    }
    final backup = BackupModel(
      poems: poems,
      config: ConfigModel(
        name: config.name ?? '',
        image: imageBytes,
      ),
      theme: theme,
    );

    final data = json.encode(backup);
    final dateTime = DateTime.now().toIso8601String();
    final tempDir = await getTemporaryDirectory();
    final file = io.File('${tempDir.path}/backup-$dateTime.json')
      ..writeAsStringSync(data);

    final drive = await _getDrive();

    await _uploadToDrive(file, drive);
    await _deleteOldBackups(drive);

    return DateTime.now();
  }

  Future<DateTime> restore() async {
    final downloadedFile = await _downloadFromDrive();

    final data = downloadedFile.readAsStringSync();

    final backup = BackupModel.fromJson(json.decode(data));

    final db = locator.get<Database>();
    final config = ref.read(configProvider.notifier);
    final theme = ref.read(themeProvider.notifier);

    await db.deleteAllPoems();
    await db.insertBatchPoems(backup.poems);

    config.name = backup.config.name;
    if (backup.config.image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final file = io.File('${appDir.path}/profile.png')
        ..writeAsBytesSync(backup.config.image!);
      config.profile = file.path;
    } else {
      config.profile = null;
    }

    if (backup.theme.accentColor == null) {
      theme.setToDynamicColor();
    } else {
      theme.setAccentColor(backup.theme.accentColor!);
    }
    theme.setTheme(backup.theme.themeType);

    await downloadedFile.delete();

    return DateTime.now();
  }

  Future<bool> hasBackup() async {
    final drive = await _getDrive();
    final files = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
      spaces: "appDataFolder",
    );
    final backupFiles = files.files;
    if (backupFiles == null || backupFiles.isEmpty) {
      return false;
    }

    return true;
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
    final account = ref.read(authProvider.notifier).getAccount();
    if (account == null) {
      throw BackupRestoreException('No account found');
    }
    final headers = await account.authHeaders;
    return gapis.DriveApi(GoogleAuthClient(headers));
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class BackupRestoreException implements Exception {
  final String message;

  BackupRestoreException(this.message);
}
