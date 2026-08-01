import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/restore_manager_provider.dart';
import 'restore_screen.dart';

class RestoreSuccessScreen extends ConsumerWidget {
  const RestoreSuccessScreen({super.key});

  static const String routePath = '/restore/success';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreState = ref.watch(restoreManagerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: switch (restoreState) {
            SuccessRestoreState() => _RestoreSuccessView(state: restoreState),
            _ => const _RestoreSuccessView(state: SuccessRestoreState()),
          },
        ),
      ),
    );
  }
}

class _RestoreSuccessView extends ConsumerWidget {
  const _RestoreSuccessView({required this.state});

  final SuccessRestoreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const Spacer(),
        Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary),
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
