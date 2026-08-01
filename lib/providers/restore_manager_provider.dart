import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/backup_model/backup_model.dart';
import 'backup_restore_manager_provider.dart';

final restoreManagerProvider =
    NotifierProvider<RestoreManagerProvider, RestoreState>(
      RestoreManagerProvider.new,
    );

class RestoreManagerProvider extends Notifier<RestoreState> {
  List<(String id, DateTime dateTime)> _cachedBackups = [];

  Future<void> checkBackup() async {
    state = const SearchingBackupRestoreState();
    try {
      final backups = await ref
          .read(backupRestoreManagerProvider)
          .getAllBackups();

      if (backups == null || backups.isEmpty) {
        state = const NotFoundBackupRestoreState();
        return;
      }

      _cachedBackups = backups;
      state = FoundBackupsRestoreState(
        backups: backups,
        selectedBackupId: backups.first.$1,
      );
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      state = ErrorRestoreState(e);
    }
  }

  void selectBackup(String backupId) {
    if (state is FoundBackupsRestoreState) {
      state = FoundBackupsRestoreState(
        backups: _cachedBackups,
        selectedBackupId: backupId,
      );
    }
  }

  Future<void> selectBackupForPreview(String backupId) async {
    final backupTuple = _cachedBackups.firstWhere(
      (b) => b.$1 == backupId,
      orElse: () => (backupId, DateTime.now()),
    );

    state = PreviewBackupRestoreState(
      backupId: backupId,
      dateTime: backupTuple.$2,
      isLoading: true,
    );

    try {
      final backupModel = await ref
          .read(backupRestoreManagerProvider)
          .getBackupModel(backupId);

      state = PreviewBackupRestoreState(
        backupId: backupId,
        dateTime: backupTuple.$2,
        backupModel: backupModel,
        isLoading: false,
      );
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      state = PreviewBackupRestoreState(
        backupId: backupId,
        dateTime: backupTuple.$2,
        isLoading: false,
        error: e,
      );
    }
  }

  void backToBackupList() {
    if (_cachedBackups.isNotEmpty) {
      String? selectedId;
      if (state is PreviewBackupRestoreState) {
        selectedId = (state as PreviewBackupRestoreState).backupId;
      }
      state = FoundBackupsRestoreState(
        backups: _cachedBackups,
        selectedBackupId: selectedId ?? _cachedBackups.first.$1,
      );
    } else {
      state = const IdleRestoreState();
    }
  }

  Future<void> restore(String backupId) async {
    state = const RestoringRestoreState();
    try {
      await ref.read(backupRestoreManagerProvider).restore(backupId);
      state = const SuccessRestoreState();
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      state = ErrorRestoreState(e);
    }
  }

  @override
  RestoreState build() {
    return const IdleRestoreState();
  }
}

sealed class RestoreState {
  const RestoreState();

  String get message;
}

class IdleRestoreState extends RestoreState {
  const IdleRestoreState();

  @override
  String get message => "Would you like to restore a backup?";
}

class SearchingBackupRestoreState extends RestoreState {
  const SearchingBackupRestoreState();

  @override
  String get message => "Searching for backups...";
}

class FoundBackupsRestoreState extends RestoreState {
  const FoundBackupsRestoreState({
    required this.backups,
    this.selectedBackupId,
  });

  final List<(String id, DateTime dateTime)> backups;
  final String? selectedBackupId;

  @override
  String get message => "Found ${backups.length} available backup(s)";
}

class PreviewBackupRestoreState extends RestoreState {
  const PreviewBackupRestoreState({
    required this.backupId,
    required this.dateTime,
    this.backupModel,
    this.isLoading = false,
    this.error,
  });

  final String backupId;
  final DateTime dateTime;
  final BackupModel? backupModel;
  final bool isLoading;
  final Object? error;

  @override
  String get message =>
      "Backup preview for ${DateFormat.yMMMEd().format(dateTime)}";
}

class NotFoundBackupRestoreState extends RestoreState {
  const NotFoundBackupRestoreState();

  @override
  String get message => "No backups found";
}

class RestoringRestoreState extends RestoreState {
  const RestoringRestoreState();

  @override
  String get message => "Restoring...";
}

class SuccessRestoreState extends RestoreState {
  const SuccessRestoreState();

  @override
  String get message => "Restored successfully";
}

class ErrorRestoreState extends RestoreState {
  const ErrorRestoreState(this.error);

  final Object error;

  @override
  String get message => "Error: $error";
}
