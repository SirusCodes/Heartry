import 'package:flutter/material.dart';

import '../../widgets/color_picker_dialog.dart';
import '../widgets/page_details.dart';
import '../widgets/poem_image_text.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class TextLayer extends ImageLayer {
  TextLayer({
    super.key,
    required this.controller,
  }) : super(nextLayer: null);

  final textScale = ValueNotifier<double>(1.0);
  final textColor = ValueNotifier<Color?>(null);

  final ImageController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentPage = PageDetails.of(context).currentPage;

    return ListenableBuilder(
      listenable: Listenable.merge([textScale, textColor]),
      builder: (context, child) {
        return PoemImageText(
          poem: controller.poemSeparated[currentPage],
          title: controller.title,
          poet: controller.author,
          color: textColor.value ?? colorScheme.onSurface,
          scale: textScale.value,
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      IconButton(
        icon: Icon(Icons.format_color_text_rounded),
        tooltip: "Text Color",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: textColor,
                  builder: (context, colorValue, child) => ColorPaletteSelector(
                    currentColor: colorValue ?? colorScheme.onSurface,
                    onColorSelected: (color) {
                      textColor.value = color;
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.format_size_rounded),
        tooltip: "Text Size",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return ValueListenableBuilder(
                valueListenable: textScale,
                builder: (context, value, child) => _TextSizeHandler(
                  value: value,
                  onChanged: (value) {
                    controller.textSizeFactor = value;
                    textScale.value = value;
                  },
                ),
              );
            },
          );
        },
      ),
      ...super.getEditingOptions(context)
    ];
  }

  @override
  void dispose() {
    textScale.dispose();
    textColor.dispose();
    super.dispose();
  }
}

class _TextSizeHandler extends StatelessWidget {
  const _TextSizeHandler({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
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
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
