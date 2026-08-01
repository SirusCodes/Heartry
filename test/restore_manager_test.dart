import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/models/backup_model/backup_model.dart';
import 'package:heartry/providers/backup_restore_manager_provider.dart';
import 'package:heartry/providers/restore_manager_provider.dart';
import 'dart:io' as io;

class FakeBackupRestoreManagerProvider implements BackupRestoreManagerProvider {
  FakeBackupRestoreManagerProvider({
    this.backupsList,
    this.backupModel,
    this.shouldThrow = false,
  });

  final List<(String id, DateTime dateTime)>? backupsList;
  final BackupModel? backupModel;
  final bool shouldThrow;
  String? restoredBackupId;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<List<(String id, DateTime dateTime)>?> getAllBackups() async {
    if (shouldThrow) throw Exception('Drive error');
    return backupsList;
  }

  @override
  Future<BackupModel> getBackupModel(String backupId) async {
    if (shouldThrow) throw Exception('Fetch error');
    return backupModel ??
        BackupModel(
          poems: [
            PoemModel(
              id: 1,
              title: 'Test Poem 1',
              poem: 'Content of test poem 1',
              poemRich: Delta()..insert('Content 1\n'),
            ),
            PoemModel(
              id: 2,
              title: 'Test Poem 2',
              poem: 'Content of test poem 2',
              poemRich: Delta()..insert('Content 2\n'),
            ),
          ],
          prefs: {},
          image: null,
        );
  }

  @override
  Future<DateTime> restore([String? backupId]) async {
    if (shouldThrow) throw Exception('Restore error');
    restoredBackupId = backupId;
    return DateTime.now();
  }

  @override
  Future<DateTime> backup(io.File file) async => DateTime.now();

  @override
  Future<io.File> createBackupFile() async => throw UnimplementedError();

  @override
  Future<String> getBackupFileHash(io.File file) async => '';

  @override
  Future<DateTime?> getLastestBackupDate() async =>
      backupsList != null && backupsList!.isNotEmpty
      ? backupsList!.first.$2
      : null;

  @override
  Future<bool> hasBackup() async =>
      backupsList != null && backupsList!.isNotEmpty;

  @override
  Future<bool> isSameAsLastBackup(String newBackupHash) async => false;

  @override
  Future<void> removeBackup(String id) async {}

  @override
  Future<void> setBackupHash(String newBackupHash) async {}
}

void main() {
  group('RestoreManagerProvider State & Transition Tests', () {
    test('Initial state is IdleRestoreState', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(restoreManagerProvider);
      expect(state, isA<IdleRestoreState>());
      expect(state.message, "Would you like to restore a backup?");
    });

    test(
      'checkBackup sets NotFoundBackupRestoreState when no backups exist',
      () async {
        final fakeManager = FakeBackupRestoreManagerProvider(backupsList: []);
        final container = ProviderContainer(
          overrides: [
            backupRestoreManagerProvider.overrideWithValue(fakeManager),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(restoreManagerProvider.notifier);
        await notifier.checkBackup();

        final state = container.read(restoreManagerProvider);
        expect(state, isA<NotFoundBackupRestoreState>());
        expect(state.message, "No backups found");
      },
    );

    test(
      'checkBackup sets FoundBackupsRestoreState when backups exist',
      () async {
        final date1 = DateTime.parse("2026-07-30T10:00:00.000");
        final date2 = DateTime.parse("2026-07-29T10:00:00.000");
        final fakeManager = FakeBackupRestoreManagerProvider(
          backupsList: [('backup-id-1', date1), ('backup-id-2', date2)],
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreManagerProvider.overrideWithValue(fakeManager),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(restoreManagerProvider.notifier);
        await notifier.checkBackup();

        final state = container.read(restoreManagerProvider);
        expect(state, isA<FoundBackupsRestoreState>());
        final foundState = state as FoundBackupsRestoreState;
        expect(foundState.backups.length, 2);
        expect(foundState.selectedBackupId, 'backup-id-1');
      },
    );

    test('selectBackup updates selectedBackupId', () async {
      final date1 = DateTime.parse("2026-07-30T10:00:00.000");
      final date2 = DateTime.parse("2026-07-29T10:00:00.000");
      final fakeManager = FakeBackupRestoreManagerProvider(
        backupsList: [('backup-id-1', date1), ('backup-id-2', date2)],
      );

      final container = ProviderContainer(
        overrides: [
          backupRestoreManagerProvider.overrideWithValue(fakeManager),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(restoreManagerProvider.notifier);
      await notifier.checkBackup();

      notifier.selectBackup('backup-id-2');

      final state =
          container.read(restoreManagerProvider) as FoundBackupsRestoreState;
      expect(state.selectedBackupId, 'backup-id-2');
    });

    test(
      'selectBackupForPreview loads backup preview and updates state',
      () async {
        final date1 = DateTime.parse("2026-07-30T10:00:00.000");
        final fakeManager = FakeBackupRestoreManagerProvider(
          backupsList: [('backup-id-1', date1)],
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreManagerProvider.overrideWithValue(fakeManager),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(restoreManagerProvider.notifier);
        await notifier.checkBackup();

        await notifier.selectBackupForPreview('backup-id-1');

        final state =
            container.read(restoreManagerProvider) as PreviewBackupRestoreState;
        expect(state.backupId, 'backup-id-1');
        expect(state.isLoading, false);
        expect(state.backupModel, isNotNull);
        expect(state.backupModel!.poems.length, 2);
        expect(state.backupModel!.poems.first.title, 'Test Poem 1');
      },
    );

    test('backToBackupList returns from PreviewBackupRestoreState '
        'to FoundBackupsRestoreState', () async {
      final date1 = DateTime.parse("2026-07-30T10:00:00.000");
      final fakeManager = FakeBackupRestoreManagerProvider(
        backupsList: [('backup-id-1', date1)],
      );

      final container = ProviderContainer(
        overrides: [
          backupRestoreManagerProvider.overrideWithValue(fakeManager),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(restoreManagerProvider.notifier);
      await notifier.checkBackup();
      await notifier.selectBackupForPreview('backup-id-1');

      notifier.backToBackupList();

      final state = container.read(restoreManagerProvider);
      expect(state, isA<FoundBackupsRestoreState>());
    });

    test('restore performs restore on selected backup '
        'and sets SuccessRestoreState', () async {
      final date1 = DateTime.parse("2026-07-30T10:00:00.000");
      final fakeManager = FakeBackupRestoreManagerProvider(
        backupsList: [('backup-id-1', date1)],
      );

      final container = ProviderContainer(
        overrides: [
          backupRestoreManagerProvider.overrideWithValue(fakeManager),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(restoreManagerProvider.notifier);
      await notifier.checkBackup();
      await notifier.selectBackupForPreview('backup-id-1');

      await notifier.restore('backup-id-1');

      final state = container.read(restoreManagerProvider);
      expect(state, isA<SuccessRestoreState>());
      expect(fakeManager.restoredBackupId, 'backup-id-1');
    });
  });
}
