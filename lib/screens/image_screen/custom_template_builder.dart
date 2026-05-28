import 'package:flutter/material.dart';

import '../../image_builder/core/image_controller.dart';
import '../../image_builder/core/image_layer.dart';

class CustomTemplateLayerConfig {
  const CustomTemplateLayerConfig({
    required this.backgroundType,
    required this.overlayTypes,
    required this.frameType,
    required this.outerPaddingH,
    required this.outerPaddingV,
    required this.innerPaddingH,
    required this.innerPaddingV,
    this.imageBase64,
  });

  final LayerType backgroundType;
  final String? imageBase64;
  final List<LayerType> overlayTypes;
  final LayerType? frameType;
  final double outerPaddingH;
  final double outerPaddingV;
  final double innerPaddingH;
  final double innerPaddingV;
}

ImageLayer _adaptFrame(
  LayerType? frameType,
  ImageLayer next,
  double innerPaddingH,
  double innerPaddingV,
) {
  if (frameType == null) {
    return next;
  }

  switch (frameType) {
    case LayerType.frostedGlass:
      final padded = PaddingLayer(
        padding: EdgeInsets.symmetric(
          horizontal: innerPaddingH,
          vertical: innerPaddingV,
        ),
        nextLayer: next,
      );
      return FrostedGlassLayer(nextLayer: padded);
    case LayerType.solidBackground:
    case LayerType.gradientBackground:
    case LayerType.imageBackground:
    case LayerType.blurOverlay:
    case LayerType.translucentOverlay:
    case LayerType.bubbleOverlay:
    case LayerType.padding:
    case LayerType.pageCounter:
    case LayerType.text:
      throw ArgumentError('Unsupported frame layer type: $frameType');
  }
}

ImageLayer _adaptOverlays(List<LayerType> overlayTypes, ImageLayer next) {
  ImageLayer current = next;
  for (final overlayType in overlayTypes) {
    switch (overlayType) {
      case LayerType.bubbleOverlay:
        current = BubbleOverlayLayer(nextLayer: current);
      case LayerType.blurOverlay:
        current = BlurOverlayLayer(nextLayer: current, initialBlur: 5.0);
      case LayerType.translucentOverlay:
        current = TranlucentOverlayLayer(
          nextLayer: current,
          initialColor: Colors.white,
          initialOpacity: 0.2,
        );
      case LayerType.solidBackground:
      case LayerType.gradientBackground:
      case LayerType.imageBackground:
      case LayerType.frostedGlass:
      case LayerType.padding:
      case LayerType.pageCounter:
      case LayerType.text:
        throw ArgumentError('Unsupported overlay layer type: $overlayType');
    }
  }
  return current;
}

ImageLayer _adaptBackground(
  LayerType backgroundType,
  ImageLayer next,
  String? imageBase64,
) {
  switch (backgroundType) {
    case LayerType.solidBackground:
      return SolidBackgroundLayer(nextLayer: next);
    case LayerType.gradientBackground:
      return GradientBackgroundLayer(nextLayer: next);
    case LayerType.imageBackground:
      return ImageBackgroundLayer(
        nextLayer: next,
        initialImageBase64: imageBase64,
      );
    case LayerType.blurOverlay:
    case LayerType.translucentOverlay:
    case LayerType.bubbleOverlay:
    case LayerType.frostedGlass:
    case LayerType.padding:
    case LayerType.pageCounter:
    case LayerType.text:
      throw ArgumentError('Unsupported background layer type: $backgroundType');
  }
}

ImageLayer buildCustomTemplateLayer(
  CustomTemplateLayerConfig config,
  ImageController controller,
) {
  ImageLayer current = TextLayer(controller: controller);

  // Adapt Frame Layer
  current = _adaptFrame(
    config.frameType,
    current,
    config.innerPaddingH,
    config.innerPaddingV,
  );

  // Apply Outer Padding Layer
  current = PaddingLayer(
    padding: EdgeInsets.symmetric(
      horizontal: config.outerPaddingH,
      vertical: config.outerPaddingV,
    ),
    nextLayer: current,
  );

  // Page Counter Layer
  current = PageCounterLayer(controller: controller, nextLayer: current);

  // Adapt Overlay Layers
  current = _adaptOverlays(config.overlayTypes, current);

  // Adapt Background Layer
  return _adaptBackground(config.backgroundType, current, config.imageBase64);
}

Map<String, dynamic> buildCustomTemplateJson(
  CustomTemplateLayerConfig config,
  ImageController controller,
) {
  final layer = buildCustomTemplateLayer(config, controller);
  return serializeCustomTemplateLayer(layer);
}

Map<String, dynamic> serializeCustomTemplateLayer(ImageLayer layer) {
  if (layer is TextLayer) {
    return {'type': layer.type.value};
  }

  final serialized = Map<String, dynamic>.from(layer.toJson()!);
  final nextLayer = layer.nextLayer;

  if (nextLayer != null) {
    serialized['next'] = serializeCustomTemplateLayer(nextLayer);
  } else {
    serialized.remove('next');
  }

  return serialized;
}
