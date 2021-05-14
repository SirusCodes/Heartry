import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';

import '../database/config.dart';
import '../init_get_it.dart';
import '../models/backup_model.dart';
import '../utils/contants.dart';
import '../utils/google_auth_client.dart';
import '../utils/theme.dart';
import 'theme_provider.dart';

final retrieveBackupProvider = Provider<RetrieveBackupProvider>((ref) {
  return RetrieveBackupProvider(ref.read);
});

class RetrieveBackupProvider {
  RetrieveBackupProvider(Reader read) : _read = read;

  final Reader _read;

  late DriveApi _driveApi;
  Future<void> saveToDB(Map<String, String> authHeaders) async {
    final authenticateClient = GoogleAuthClient(authHeaders);
    _driveApi = DriveApi(authenticateClient);

    final fileList = await _driveApi.files
        .list(spaces: "appDataFolder", orderBy: "createdTime");

    final files = fileList.files;

    if (files != null && files.isEmpty) return;

    final userConfig = files?.firstWhere(
      (file) => file.name == "$USER_CONFIG.json",
    );

    if (userConfig != null) {
      final fileData = await _getFileData(userConfig.id!) as Media;
      final dataStore = <int>[];

      fileData.stream.listen(
        (data) => dataStore.addAll(data),
        onDone: () {
          final backupModel = _getUserConfig(dataStore);
          locator<Config>().name = backupModel.name;
          _read(themeProvider.notifier)
              .setTheme(stringToTheme(backupModel.theme));
        },
        cancelOnError: true,
      );
    }
  }

  BackupModel _getUserConfig(List<int> data) {
    final jsonData = String.fromCharCodes(data);

    return BackupModel.fromJson(jsonData);
  }

  Future _getFileData(String fileId) => _driveApi.files.get(
        fileId,
        downloadOptions: DownloadOptions.fullMedia,
      );
}
