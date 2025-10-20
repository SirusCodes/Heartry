import 'package:flutter/material.dart';

import '../../widgets/color_picker_dialog.dart';
import '../../widgets/gradient_palette_selector.dart';
import '../core/image_layer.dart';

class SolidBackgroundLayer extends ImageLayer {
  SolidBackgroundLayer({
    super.key,
    required super.nextLayer,
  });

  final color = ValueNotifier<Color?>(null);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    color.value ??= primaryColor;

    return ValueListenableBuilder(
      valueListenable: color,
      builder: (context, colorValue, child) {
        if (colorValue == null) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: colorValue,
          child: nextLayer!.build(context),
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.texture_rounded),
        tooltip: "Background Color",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
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
      ...super.getEditingOptions(context),
    ];
  }

  @override
  void dispose() {
    color.dispose();
    super.dispose();
  }
}

class GradientBackgroundLayer extends ImageLayer {
  GradientBackgroundLayer({super.key, super.nextLayer});

  final gradient = ValueNotifier<List<Color>?>(null);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    gradient.value ??= [primaryColor, primaryColor.withValues(alpha: 0.7)];

    return ValueListenableBuilder(
      valueListenable: gradient,
      builder: (context, gradientValue, child) {
        if (gradientValue == null || gradientValue.length < 2) {
          return const SizedBox.shrink();
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientValue,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: nextLayer?.build(context),
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.gradient_rounded),
        tooltip: "Background Gradient",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: gradient,
                  builder: (context, value, child) => GradientPaletteSelector(
                    gradient: value!,
                    onChanged: (value) {
                      gradient.value = value;
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      ...super.getEditingOptions(context),
    ];
  }

  @override
  void dispose() {
    gradient.dispose();
    super.dispose();
  }
}
