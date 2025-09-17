import 'package:flutter/material.dart';

import '../../../widgets/color_picker_dialog.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class SolidBackgroundLayer extends ImageLayer {
  SolidBackgroundLayer({super.nextLayer});

  final color = ValueNotifier<Color?>(null);

  static const padding = EdgeInsets.symmetric(
    horizontal: 40,
    vertical: 50,
  );

  @override
  EdgeInsets getPadding() {
    return padding + super.getPadding();
  }

  @override
  Widget build(
    BuildContext context,
    ImageController controller,
    int currentPage,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    color.value ??= primaryColor;

    return ValueListenableBuilder(
      valueListenable: color,
      builder: (context, colorValue, child) {
        return Container(
          padding: padding,
          color: colorValue,
          child: super.build(
            context,
            controller,
            currentPage,
          ),
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(ImageController controller) {
    return [
      IconButton(
        icon: Icon(Icons.texture_rounded),
        onPressed: () {
          showModalBottomSheet<void>(
            context: controller.context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorPaletteSelector(
                  currentColor: color.value,
                  onColorSelected: (value) {
                    color.value = value;
                  },
                ),
              );
            },
          );
        },
      ),
      ...super.getEditingOptions(controller),
    ];
  }
}
