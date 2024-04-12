import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/restore_manager_provider.dart';
import '../poems_screen/poems_screen.dart';

class RestoreScreen extends ConsumerWidget {
  const RestoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreManagerProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            restoreState.message,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildButtonBar(
              restoreState: restoreState,
              context: context,
              ref: ref,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar({
    required RestoreState restoreState,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return switch (restoreState) {
      IdleRestoreState() => _buildIdle(context, ref),
      SearchingBackupRestoreState() ||
      RestoringRestoreState() =>
        const SizedBox.shrink(),
      FoundBackupRestoreState() => _buildFoundRestoreButtons(context, ref),
      NotFoundBackupRestoreState() ||
      SuccessRestoreState() ||
      ErrorRestoreState() =>
        _buildNextButton(context),
    };
  }

  Widget _buildNextButton(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PoemScreen()),
      ),
      child: const Text("Next"),
    );
  }

  Widget _buildFoundRestoreButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: _skipButton(context)),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => ref //
                .read(restoreManagerProvider.notifier)
                .restore(),
            child: const Text('Restore'),
          ),
        ),
      ],
    );
  }

  Widget _buildIdle(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: _skipButton(context)),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => ref //
                .read(restoreManagerProvider.notifier)
                .checkBackup(),
            child: const Text('Check backup'),
          ),
        ),
      ],
    );
  }

  Widget _skipButton(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PoemScreen()),
      ),
      child: const Text("Skip"),
    );
  }
}
