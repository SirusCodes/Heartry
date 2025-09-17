import 'package:flutter/material.dart';

import '../../../widgets/color_picker_dialog.dart';
import '../../image_screen/widgets/poem_image_text.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class TextLayer extends ImageLayer {
  TextLayer() : super(nextLayer: null);

  final textScale = ValueNotifier(1.0);
  final textColor = ValueNotifier<Color?>(null);

  @override
  Widget build(
    BuildContext context,
    ImageController controller,
    int currentPage,
  ) {
    return PoemImageText(
      poem: controller.poemSeparated[currentPage],
      title: controller.title,
      poet: controller.author,
      color: controller.textStyle.color!,
      scale: controller.textSizeFactor,
    );
  }

  @override
  List<Widget> getEditingOptions(ImageController controller) {
    return [
      IconButton(
        icon: Icon(Icons.format_color_text_rounded),
        onPressed: () {
          showModalBottomSheet<void>(
            context: controller.context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: textColor,
                  builder: (context, colorValue, child) => ColorPaletteSelector(
                    currentColor: colorValue ?? controller.textStyle.color!,
                    onColorSelected: (color) {
                      textColor.value = color;
                      controller.textStyle = controller.textStyle.copyWith(
                        color: color,
                      );
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
        onPressed: () {
          showModalBottomSheet<void>(
            context: controller.context,
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
      ...super.getEditingOptions(controller)
    ];
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
