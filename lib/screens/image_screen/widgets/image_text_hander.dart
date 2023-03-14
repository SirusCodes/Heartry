import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/text_providers.dart';
import '../../../widgets/color_picker_dialog.dart';

class ImageTextHandler extends ConsumerWidget {
  const ImageTextHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(textSizeProvider);
    final color = ref.watch(textColorProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Customize Text",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          const Text(
            "Color",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => showColorPicker(
              context: context,
              currentColor: color,
              onOkPressed: (color) =>
                  ref.read(textColorProvider.notifier).state = color,
            ),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black45,
                ),
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Size",
            style: TextStyle(fontSize: 18),
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
    );
  }
}
