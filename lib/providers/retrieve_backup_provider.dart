import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../init_get_it.dart';
import '../models/backup_model.dart';
import '../utils/contants.dart';
import '../utils/google_auth_client.dart';
import '../utils/theme.dart';
import 'shared_prefs_provider.dart';
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

    final sharedPrefs = _read(sharedPrefsProvider);

    final userConfig = files?.firstWhere(
      (file) => file.name == "$USER_CONFIG.json",
    );

    if (userConfig != null) {
      _extractAndSaveData(userConfig.id!, (data) {
        final backupModel = _getUserConfig(data);
        sharedPrefs.name = backupModel.name;
        _read(themeProvider.notifier)
            .setTheme(stringToTheme(backupModel.theme));
      });
    }

    final userPoems = files?.firstWhere(
      (file) => file.name == "$USER_POEM.json",
    );

    if (userPoems != null) {
      _extractAndSaveData(userPoems.id!, (data) async {
        final poemModels = _getUserPoems(data);
        await locator<Database>().insertAllPoem(poemModels);
      });
    }

    final userProfile = files?.firstWhere(
      (file) => file.name!.contains(USER_PROFILE),
    );

    if (userProfile != null) {
      _extractAndSaveData(userProfile.id!, (data) async {
        imageCache!.clear();

        final directory = await getApplicationDocumentsDirectory();

        final imageSaved = p.join(directory.path, userProfile.name);
        final image = await io.File(imageSaved).writeAsBytes(data);

        _read(sharedPrefsProvider).profile = image.path;
      });
    }
  }

  Future<void> _extractAndSaveData(
    String id,
    Function(List<int> data) onDoneSave,
  ) async {
    final fileData = await _getFileData(id) as Media;
    final dataStore = <int>[];

    fileData.stream.listen(
      (data) => dataStore.addAll(data),
      onDone: () => onDoneSave.call(dataStore),
      cancelOnError: true,
    );
  }

  List<PoemModel> _getUserPoems(List<int> data) {
    final jsonData = String.fromCharCodes(data);
    final list = json.decode(jsonData) as List;
    return list
        .map((e) => PoemModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
