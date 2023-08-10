import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:heartry/database/config.dart';
import 'package:heartry/providers/auth_provider.dart';
import 'package:heartry/screens/about_screen/widgets/base_info_widget.dart';
import 'package:heartry/widgets/c_screen_title.dart';
import 'package:heartry/widgets/only_back_button_bottom_app_bar.dart';

import '../../providers/backup_restore_manager_provider.dart';

class BackupSettingScreen extends ConsumerWidget {
  const BackupSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);
    final config = ref.watch(configProvider);

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    ref.listen(
      backupManagerProvider,
      (previous, next) => _onBackupManagerUpdate(previous, next, context),
    );

    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            const CScreenTitle(title: "Backup Setting"),
            isAuthenticated.when(
              data: (user) => BaseInfoWidget(
                title: "BACKUP",
                children: [
                  SwitchListTile(
                    value: user != null,
                    title: const Text("Backup to Google Drive"),
                    subtitle: const Text(
                      "Enable auto backup your data to Google Drive. "
                      "You can restore your data on another device.",
                    ),
                    onChanged: (value) {
                      if (value) {
                        ref.read(authProvider.notifier).signIn();
                      } else {
                        ref.read(authProvider.notifier).signOut();
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Backup Now"),
                    subtitle: const Text(
                      "Backup your data to Google Drive immediately.",
                    ),
                    onTap: () {
                      ref.read(backupManagerProvider.notifier).backup();
                    },
                  ),
                  ListTile(
                    title: const Text("Last Backup"),
                    subtitle: config.lastBackup == null
                        ? const Text("Have no backup yet")
                        : Text(
                            DateFormat.yMEd()
                                .add_jm()
                                .format(config.lastBackup!),
                          ),
                  )
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text(e.toString())),
            ),
          ],
        ),
        bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
      ),
    );
  }

  void _onBackupManagerUpdate(BackupRestoreState? previous,
      BackupRestoreState next, BuildContext context) {
    if (next == BackupRestoreState.backingUp) {
      _showBackupDialog(context);
    } else if (next == BackupRestoreState.success) {
      Navigator.pop(context);
    } else if (next == BackupRestoreState.error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Backup failed"),
        ),
      );
    }
  }

  _showBackupDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Backup in progress, don't close the app"),
        content: CircularProgressIndicator(),
      ),
    );
  }
}
