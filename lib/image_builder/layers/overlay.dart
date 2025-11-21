import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../database/config.dart';
import '../../widgets/color_picker_dialog.dart';
import '../core/image_layer.dart';
import '../widgets/editing_option.dart';
import '../widgets/slider_option.dart';

class BlurOverlayLayer extends ImageLayer {
  BlurOverlayLayer({super.key, super.nextLayer});

  final blur = ValueNotifier<double>(5.0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: blur,
      builder: (context, value, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
          child: nextLayer!.build(context),
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      EditingOption(
        option: "Blur",
        icon: Icon(Symbols.blur_circular_rounded),
        tooltip: "Blur background",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ValueListenableBuilder(
              valueListenable: blur,
              builder: (context, value, child) {
                return SliderOption(
                  title: "Customize Blur",
                  value: value,
                  onChanged: (newValue) {
                    blur.value = newValue;
                  },
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: value.toStringAsFixed(0),
                );
              },
            ),
          );
        },
      ),
      ...super.getEditingOptions(context),
    ];
  }
}

class TranlucentOverlayLayer extends ImageLayer {
  TranlucentOverlayLayer({super.key, required super.nextLayer});

  final opacity = ValueNotifier<double>(0.2);
  final color = ValueNotifier<Color>(Colors.white);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([opacity, color]),
      builder: (context, child) => ColoredBox(
        color: color.value.withValues(alpha: opacity.value),
        child: child,
      ),
      child: nextLayer!.build(context),
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    return [
      EditingOption(
        option: "Overlay Opacity",
        icon: Icon(Symbols.masked_transitions_rounded),
        tooltip: "Adjust Overlay Opacity",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ValueListenableBuilder(
              valueListenable: opacity,
              builder: (context, value, child) {
                return SliderOption(
                  title: "Customize Opacity",
                  value: value * 100,
                  label: "${(value * 100).toStringAsFixed(0)}%",
                  onChanged: (newValue) {
                    opacity.value = newValue / 100;
                  },
                  min: 0,
                  max: 100,
                  divisions: 10,
                );
              },
            ),
          );
        },
      ),
      EditingOption(
        option: "Overlay Color",
        icon: Icon(Icons.texture_rounded),
        tooltip: "Overlay Color",
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
}

class BubbleOverlayLayer extends ImageLayer {
  const BubbleOverlayLayer({super.key, super.nextLayer});

  @override
  Widget build(BuildContext context) {
    return _BubbleOverlayWidget(child: nextLayer!.build(context));
  }
}

class _BubbleOverlayWidget extends StatelessWidget {
  const _BubbleOverlayWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: SizedBox.expand(
        child: Theme(
          data: ThemeData(
            colorScheme: colorScheme.copyWith(
              primaryContainer: Colors.white.withValues(alpha: .3),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned(
                top: -30,
                left: -30,
                child: CircleAvatar(radius: 80),
              ),
              const Positioned(
                top: 200,
                right: -10,
                child: CircleAvatar(radius: 40),
              ),
              const Positioned(
                bottom: -30,
                left: 0,
                child: CircleAvatar(radius: 75),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(radius: 50),
              ),
              const Positioned(
                bottom: 250,
                right: 110,
                child: CircleAvatar(radius: 20),
              ),
              Center(child: child),
              Consumer(
                builder: (context, ref, child) {
                  final config = ref.watch(configProvider);

                  return config.maybeWhen(
                    data: (data) {
                      if (data.profile != null)
                        return Positioned(
                          bottom: 20,
                          right: 20,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: FileImage(File(data.profile!)),
                          ),
                        );

                      return const SizedBox.shrink();
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
