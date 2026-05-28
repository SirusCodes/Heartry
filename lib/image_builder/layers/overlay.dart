part of '../core/image_layer.dart';

sealed class OverlayLayer extends ImageLayer {
  const OverlayLayer({super.key, required super.nextLayer});
}

class BlurOverlayLayer extends OverlayLayer {
  BlurOverlayLayer({super.key, required super.nextLayer, double? initialBlur}) {
    if (initialBlur != null) {
      blur.value = initialBlur;
    }
  }

  factory BlurOverlayLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final blurVal = (json['blur'] as num?)?.toDouble();
    return BlurOverlayLayer(nextLayer: nextLayer!, initialBlur: blurVal);
  }

  @override
  LayerType get type => LayerType.blurOverlay;

  final blur = ValueNotifier<double>(5.0);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.value, 'blur': blur.value, 'next': super.toJson()};
  }

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

class TranlucentOverlayLayer extends OverlayLayer {
  TranlucentOverlayLayer({
    super.key,
    required super.nextLayer,
    Color? initialColor,
    double? initialOpacity,
  }) {
    if (initialColor != null) {
      color.value = initialColor;
    }
    if (initialOpacity != null) {
      opacity.value = initialOpacity;
    }
  }

  factory TranlucentOverlayLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final colorVal = json['color'] as int?;
    final opacityVal = (json['opacity'] as num?)?.toDouble();
    return TranlucentOverlayLayer(
      nextLayer: nextLayer!,
      initialColor: colorVal != null ? Color(colorVal) : null,
      initialOpacity: opacityVal,
    );
  }

  @override
  LayerType get type => LayerType.translucentOverlay;

  final opacity = ValueNotifier<double>(0.2);
  final color = ValueNotifier<Color>(Colors.white);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'color': color.value.toARGB32(),
      'opacity': opacity.value,
      'next': super.toJson(),
    };
  }

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

class BubbleOverlayLayer extends OverlayLayer {
  const BubbleOverlayLayer({super.key, required super.nextLayer});

  factory BubbleOverlayLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    return BubbleOverlayLayer(nextLayer: nextLayer!);
  }

  @override
  LayerType get type => LayerType.bubbleOverlay;

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.value, 'next': super.toJson()};
  }

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
