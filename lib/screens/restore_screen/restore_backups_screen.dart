import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/restore_manager_provider.dart';
import 'restore_preview_screen.dart';
import 'restore_screen.dart';

class RestoreBackupsScreen extends ConsumerWidget {
  const RestoreBackupsScreen({super.key});

  static const String routePath = '/restore/backups';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Backup")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: switch (restoreState) {
            FoundBackupsRestoreState() => _RestoreBackupsListView(
              state: restoreState,
            ),
            _ => const RestoreLoadingWidget(message: "Loading backups..."),
          },
        ),
      ),
    );
  }
}

class _RestoreBackupsListView extends ConsumerWidget {
  const _RestoreBackupsListView({required this.state});

  final FoundBackupsRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Available Backups", style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          "Select a backup to view its poems and restore.",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RadioGroup<String>(
            groupValue: state.selectedBackupId,
            onChanged: (val) {
              if (val != null) {
                ref.read(restoreManagerProvider.notifier).selectBackup(val);
              }
            },
            child: ListView.builder(
              itemCount: state.backups.length,
              itemBuilder: (context, index) {
                final backup = state.backups[index];
                final isSelected = backup.$1 == state.selectedBackupId;

                return _BackupOptionCard(
                  isSelected: isSelected,
                  backup: backup,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: RestoreSkipButton()),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: state.selectedBackupId != null
                    ? () => _restore(ref, context)
                    : null,
                child: const Text('Preview & Restore'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _restore(WidgetRef ref, BuildContext context) {
    ref
        .read(restoreManagerProvider.notifier)
        .selectBackupForPreview(state.selectedBackupId!);
    context.push(RestorePreviewScreen.routePath);
  }
}

class _BackupOptionCard extends ConsumerWidget {
  const _BackupOptionCard({required this.isSelected, required this.backup});

  final bool isSelected;
  final (String, DateTime) backup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat.yMMMEd().add_jm().format(backup.$2);

    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Radio<String>(value: backup.$1),
        title: Text(
          formattedDate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Backup ID: ${backup.$1}"),
        onTap: () {
          ref.read(restoreManagerProvider.notifier).selectBackup(backup.$1);
        },
      ),
    );
  }
}
