part of '../core/image_layer.dart';

sealed class BackgroundLayer extends ImageLayer {
  const BackgroundLayer({super.key, required super.nextLayer});
}

class SolidBackgroundLayer extends BackgroundLayer {
  SolidBackgroundLayer({
    super.key,
    required super.nextLayer,
    Color? initialColor,
  }) {
    if (initialColor != null) {
      color.value = initialColor;
    }
  }

  factory SolidBackgroundLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final colorVal = json['color'] as int?;
    return SolidBackgroundLayer(
      nextLayer: nextLayer!,
      initialColor: colorVal != null ? Color(colorVal) : null,
    );
  }

  @override
  LayerType get type => LayerType.solidBackground;

  final color = ValueNotifier<Color?>(null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'color': color.value?.toARGB32(),
      'next': super.toJson(),
    };
  }

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

class GradientBackgroundLayer extends BackgroundLayer {
  GradientBackgroundLayer({
    super.key,
    super.nextLayer,
    List<Color>? initialGradient,
  }) {
    if (initialGradient != null) {
      gradient.value = initialGradient;
    }
  }

  factory GradientBackgroundLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final gradientList = json['gradient'] as List<dynamic>?;
    return GradientBackgroundLayer(
      nextLayer: nextLayer!,
      initialGradient: gradientList?.map((c) => Color(c as int)).toList(),
    );
  }

  @override
  LayerType get type => LayerType.gradientBackground;

  final gradient = ValueNotifier<List<Color>?>(null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'gradient': gradient.value?.map((c) => c.toARGB32()).toList(),
      'next': super.toJson(),
    };
  }

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

class ImageBackgroundLayer extends BackgroundLayer {
  ImageBackgroundLayer({
    super.key,
    super.nextLayer,
    String? initialImageBase64,
  }) {
    if (initialImageBase64 != null) {
      imageBase64.value = initialImageBase64;
    }
  }

  factory ImageBackgroundLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final imageBase64 = json['image_base64'] as String?;
    return ImageBackgroundLayer(
      nextLayer: nextLayer!,
      initialImageBase64: imageBase64,
    );
  }

  @override
  LayerType get type => LayerType.imageBackground;

  final imageBase64 = ValueNotifier<String?>(null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'image_base64': imageBase64.value,
      'next': super.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: imageBase64,
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
              image: MemoryImage(base64Decode(value)),
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
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      imageBase64.value = base64Encode(bytes);
    }
  }

  @override
  void dispose() {
    imageBase64.dispose();
    super.dispose();
  }
}
