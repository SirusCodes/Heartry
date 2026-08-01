import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/config.dart';
import '../../providers/restore_manager_provider.dart';
import '../poems_screen/poems_screen.dart';
import 'restore_backups_screen.dart';

class RestoreScreen extends ConsumerWidget {
  const RestoreScreen({super.key});

  static const String routePath = '/restore';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreManagerProvider);

    ref.listen<RestoreState>(restoreManagerProvider, (prev, next) {
      if (next is FoundBackupsRestoreState &&
          prev is SearchingBackupRestoreState) {
        context.push(RestoreBackupsScreen.routePath);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: switch (restoreState) {
            SearchingBackupRestoreState() => const RestoreLoadingWidget(
              message: "Searching for backups...",
            ),
            NotFoundBackupRestoreState() => _RestoreNotFoundView(
              state: restoreState,
            ),
            ErrorRestoreState() => _RestoreErrorView(state: restoreState),
            _ => _RestoreIdleView(
              state: restoreState is IdleRestoreState
                  ? restoreState
                  : const IdleRestoreState(),
            ),
          },
        ),
      ),
    );
  }
}

class RestoreLoadingWidget extends StatelessWidget {
  const RestoreLoadingWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class RestoreSkipButton extends ConsumerWidget {
  const RestoreSkipButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.tonal(
      onPressed: () {
        ref.read(configProvider.notifier).hasCompletedOnboarding = true;
        context.replace(PoemScreen.routePath);
      },
      child: const Text("Skip"),
    );
  }
}

class RestoreNextButton extends ConsumerWidget {
  const RestoreNextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          ref.read(configProvider.notifier).hasCompletedOnboarding = true;
          context.go(PoemScreen.routePath);
        },
        child: const Text("Next"),
      ),
    );
  }
}

class _RestoreIdleView extends ConsumerWidget {
  const _RestoreIdleView({required this.state});

  final IdleRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const Spacer(),
        Icon(
          Icons.cloud_download_outlined,
          size: 64,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          state.message,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            const Expanded(child: RestoreSkipButton()),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () =>
                    ref.read(restoreManagerProvider.notifier).checkBackup(),
                child: const Text('Check backups'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RestoreNotFoundView extends ConsumerWidget {
  const _RestoreNotFoundView({required this.state});

  final NotFoundBackupRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const Spacer(),
        Icon(Icons.cloud_off_outlined, size: 64, color: colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          state.message,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        const RestoreNextButton(),
      ],
    );
  }
}

class _RestoreErrorView extends ConsumerWidget {
  const _RestoreErrorView({required this.state});

  final ErrorRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const Spacer(),
        Icon(Icons.error_outline, size: 64, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          state.message,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        const RestoreNextButton(),
      ],
    );
  }
}
