import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/restore_manager_provider.dart';
import '../poems_screen/widgets/poem_card.dart';
import 'restore_screen.dart';
import 'restore_success_screen.dart';

class RestorePreviewScreen extends ConsumerWidget {
  const RestorePreviewScreen({super.key});

  static const String routePath = '/restore/preview';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreManagerProvider);

    ref.listen<RestoreState>(restoreManagerProvider, (prev, next) {
      if (next is SuccessRestoreState) {
        context.go(RestoreSuccessScreen.routePath);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Backup Content Preview")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: switch (restoreState) {
            PreviewBackupRestoreState() => _RestorePreviewView(
              state: restoreState,
            ),
            RestoringRestoreState() => const RestoreLoadingWidget(
              message: "Restoring data...",
            ),
            SuccessRestoreState() => const RestoreLoadingWidget(
              message: "Restored successfully!",
            ),
            _ => const RestoreLoadingWidget(message: "Loading preview..."),
          },
        ),
      ),
    );
  }
}

class _RestorePreviewView extends ConsumerWidget {
  const _RestorePreviewView({required this.state});

  final PreviewBackupRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const RestoreLoadingWidget(message: "Fetching backup contents...");
    }

    if (state.error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Failed to load preview: ${state.error}"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(restoreManagerProvider.notifier)
                  .selectBackupForPreview(state.backupId);
            },
            child: const Text("Retry"),
          ),
        ],
      );
    }

    final model = state.backupModel;
    if (model == null) {
      return const Center(child: Text("No preview data available"));
    }

    final poems = model.poems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: poems.isEmpty
              ? const Center(child: Text("No poems in this backup"))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: poems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return PoemCard(model: poems[index], onPressed: () {});
                  },
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    ref
                        .read(restoreManagerProvider.notifier)
                        .backToBackupList();
                  }
                },
                child: const Text("Back"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(restoreManagerProvider.notifier)
                      .restore(state.backupId);
                },
                child: const Text('Confirm Restore'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
