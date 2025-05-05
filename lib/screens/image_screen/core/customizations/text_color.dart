import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/text_providers.dart';
import '../../../../widgets/color_picker_dialog.dart';

class TextColor extends ConsumerWidget {
  const TextColor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(textColorProvider);

    return IconButton(
      icon: Icon(
        Icons.format_color_text_rounded,
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPaletteSelector(
                currentColor: color,
                onColorSelected: (value) =>
                    ref.read(textColorProvider.notifier).state = value,
              ),
            );
          },
        );
      },
    );
  }
}
