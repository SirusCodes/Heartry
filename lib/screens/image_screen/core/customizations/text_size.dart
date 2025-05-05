import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/text_providers.dart';

class TextSize extends StatelessWidget {
  const TextSize({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.format_size_rounded),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return const _TextSizeHandler();
          },
        );
      },
    );
  }
}

class _TextSizeHandler extends ConsumerWidget {
  const _TextSizeHandler();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(textSizeProvider);

    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "${value.toStringAsPrecision(2)}x",
              style: TextStyle(fontSize: 20),
            ),
            Slider(
              value: value,
              min: 0.8,
              max: 2,
              divisions: 12,
              label: value.toStringAsPrecision(2),
              onChanged: (value) {
                ref.read(textSizeProvider.notifier).state = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
