import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as gapis;
import 'package:heartry/database/database.dart';
import 'package:heartry/init_get_it.dart';
import 'package:heartry/providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../database/config.dart';
import '../models/backup_model/backup_model.dart';
import 'auth_provider.dart';

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

    final uploadedFile = await _uploadToDrive(file);

    return uploadedFile.createdTime!;
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

  Future<io.File> _downloadFromDrive() async {
    final drive = await _getDrive();
    final files = await drive.files.list(
      orderBy: "createdTime desc",
      q: "name contains 'backup-'",
    );
    final backup = files.files?.first;
    if (backup == null) {
      throw BackupRestoreException('No backup found');
    }

    final file = drive.files.get(
      backup.id!,
      downloadOptions: gapis.DownloadOptions.fullMedia,
    ) as gapis.Media;

    final tempDir = await getTemporaryDirectory();
    final downloadedFile = io.File('${tempDir.path}/${backup.name}');

    if (downloadedFile.existsSync()) {
      downloadedFile.deleteSync();
    }

    downloadedFile.createSync();

    await file.stream.pipe(downloadedFile.openWrite());
    return downloadedFile;
  }

  Future<gapis.File> _uploadToDrive(io.File ioFile) async {
    final drive = await _getDrive();
    final file = gapis.File()..name = ioFile.path.split('/').last;

    final media = gapis.Media(
      ioFile.openRead(),
      ioFile.lengthSync(),
      contentType: 'application/json',
    );
    final uploadedFile = await drive.files.create(file, uploadMedia: media);

    return uploadedFile;
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
