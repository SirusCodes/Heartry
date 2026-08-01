import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/models/backup_model/backup_model.dart';
import 'package:heartry/providers/backup_restore_manager_provider.dart';
import 'package:heartry/screens/restore_screen/restore_screen.dart';
import 'package:heartry/utils/router.dart';

import 'restore_manager_test.dart';

void main() {
  group('Multi-screen Restore Flow Tests', () {
    testWidgets('Renders idle state on initial RestoreScreen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RestoreScreen())),
      );

      expect(find.text('Would you like to restore a backup?'), findsOneWidget);
      expect(find.text('Check backups'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Navigates to RestoreBackupsScreen when backups are found', (
      tester,
    ) async {
      final date = DateTime.parse('2026-07-30T10:00:00.000');
      final fakeManager = FakeBackupRestoreManagerProvider(
        backupsList: [('backup-1', date)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupRestoreManagerProvider.overrideWithValue(fakeManager),
          ],
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );

      // Navigate to /restore
      goRouter.go(RestoreScreen.routePath);
      await tester.pumpAndSettle();

      // Trigger checkBackup
      await tester.tap(find.text('Check backups'));
      await tester.pumpAndSettle();

      expect(find.text('Available Backups'), findsOneWidget);
      expect(find.text('Backup ID: backup-1'), findsOneWidget);
      expect(find.text('Preview & Restore'), findsOneWidget);
    });

    testWidgets(
      'Navigates to RestorePreviewScreen when Preview & Restore is tapped',
      (tester) async {
        final date = DateTime.parse('2026-07-30T10:00:00.000');
        final backupModel = BackupModel(
          poems: [
            PoemModel(
              id: 10,
              title: 'Sample Preview Poem',
              poem: 'Sample preview line 1\nSample line 2',
              poemRich: Delta()..insert('Sample preview line 1\n'),
              lastEdit: date,
            ),
          ],
          prefs: {},
          image: null,
        );

        final fakeManager = FakeBackupRestoreManagerProvider(
          backupsList: [('backup-1', date)],
          backupModel: backupModel,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              backupRestoreManagerProvider.overrideWithValue(fakeManager),
            ],
            child: MaterialApp.router(routerConfig: goRouter),
          ),
        );

        // Navigate to /restore
        goRouter.go(RestoreScreen.routePath);
        await tester.pumpAndSettle();

        // Step 1: Check backups
        await tester.tap(find.text('Check backups'));
        await tester.pumpAndSettle();

        // Step 2: Tap Preview & Restore
        await tester.tap(find.text('Preview & Restore'));
        await tester.pumpAndSettle();

        // Step 3: Verify preview screen content
        expect(find.text('Backup Content Preview'), findsOneWidget);
        expect(find.text('Sample Preview Poem'), findsOneWidget);
        expect(
          find.text('Sample preview line 1\nSample line 2'),
          findsOneWidget,
        );
        expect(find.text('Confirm Restore'), findsOneWidget);
      },
    );
  });
}
