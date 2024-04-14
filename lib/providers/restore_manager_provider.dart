import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'backup_restore_manager_provider.dart';

final restoreManagerProvider =
    NotifierProvider<RestoreManagerProvider, RestoreState>(
  RestoreManagerProvider.new,
);

class RestoreManagerProvider extends Notifier<RestoreState> {
  Future<void> checkBackup() async {
    state = const SearchingBackupRestoreState();
    try {
      final date = await ref //
          .read(backupRestoreManagerProvider)
          .getLastestBackupDate();

      if (date == null) {
        state = const NotFoundBackupRestoreState();
        return;
      }

      state = FoundBackupRestoreState(date);
    } catch (e) {
      state = ErrorRestoreState(e);
    }
  }

  Future<void> restore() async {
    state = const RestoringRestoreState();
    try {
      await ref.read(backupRestoreManagerProvider).restore();
      state = const SuccessRestoreState();
    } catch (e) {
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

class FoundBackupRestoreState extends RestoreState {
  const FoundBackupRestoreState(this.date);

  final DateTime date;

  @override
  String get message => "Found backup from ${DateFormat.yMMMEd().format(date)}";
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
