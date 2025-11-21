import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heartry/image_builder/widgets/editing_option.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../widgets/color_picker_dialog.dart';
import '../../widgets/gradient_palette_selector.dart';
import '../core/image_layer.dart';

class SolidBackgroundLayer extends ImageLayer {
  SolidBackgroundLayer({super.key, required super.nextLayer});

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

        return ColoredBox(color: colorValue, child: nextLayer!.build(context));
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      EditingOption(
        option: "Background",
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
    final colorScheme = Theme.of(context).colorScheme;
    gradient.value ??= [colorScheme.primary, colorScheme.secondary];

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
      EditingOption(
        option: "Background",
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

class ImageBackgroundLayer extends ImageLayer {
  ImageBackgroundLayer({super.key, super.nextLayer});

  final filePath = ValueNotifier<XFile?>(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: filePath,
      builder: (context, value, child) {
        if (value == null) {
          _pickImage();

          return ColoredBox(
            color: Colors.white,
            child: nextLayer!.build(context),
          );
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(filePath.value!.path)),
              fit: BoxFit.cover,
            ),
          ),
          child: nextLayer!.build(context),
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      EditingOption(
        option: "Background",
        icon: Icon(Symbols.image_search_rounded),
        tooltip: "Background Image",
        onPressed: _pickImage,
      ),
      ...super.getEditingOptions(context),
    ];
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked != null) {
      filePath.value = picked;
    }
  }

  @override
  void dispose() {
    filePath.dispose();
    super.dispose();
  }
}
