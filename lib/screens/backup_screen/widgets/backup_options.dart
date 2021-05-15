import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/backup_manager_provider.dart';
import '../../../providers/backup_time_provider.dart';
import '../../about_screen/widgets/base_info_widget.dart';
import '../backup_screen.dart';

class BackupOptions extends StatelessWidget {
  const BackupOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        BackupInfo(),
        DriveInfo(),
      ],
    );
  }
}

class BackupInfo extends StatelessWidget {
  const BackupInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInfoWidget(
      title: "Backup information",
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              Text(
                "Backup you data on Google drive restore them"
                " when you reinstall Heartry on other device.",
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Last backup:"),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: () async {
                  await context.read(backupManagerProvider).run();
                },
                icon: const Icon(Icons.backup_rounded),
                label: const Text("Backup now"),
              ),
              const SizedBox(height: 15),
            ],
          ),
        )
      ],
    );
  }
}

class DriveInfo extends ConsumerWidget {
  const DriveInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final user = watch(googleUserInfoProvider);
    final backupTime = watch(backupTimeProvider);
    return BaseInfoWidget(
      title: "Drive information",
      children: <Widget>[
        ListTile(
          title: const Text("Google account"),
          subtitle: Text(user.email),
        ),
        ListTile(
          title: const Text("Auto backup"),
          subtitle: Text(backupTime.toFormatedString()),
          onTap: () async {
            final result = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 2, minute: 0),
            );

            if (result != null)
              context.read(backupTimeProvider.notifier).setBackupTime(result);
          },
        ),
      ],
    );
  }
}
