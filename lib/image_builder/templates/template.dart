import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class Template {
  final int? id;
  final String name;
  final String data;
  final bool isDefault;

  Template({
    this.id,
    required this.name,
    required this.data,
    this.isDefault = false,
  });

  ImageLayer getLayers(ImageController controller) {
    final Map<String, dynamic> decoded = json.decode(data);
    return buildLayerChainFromJson(decoded, controller);
  }

  Widget getIcon(BuildContext context) {
    if (name.contains('Solid')) {
      return const Icon(Icons.circle);
    } else if (name.contains('Gradient')) {
      return const Icon(Icons.gradient);
    } else if (name.contains('Image')) {
      return const Icon(Symbols.image_rounded);
    }
    return const Icon(Icons.brush_rounded);
  }
}

ImageLayer buildLayerChainFromJson(
  Map<String, dynamic> jsonMap,
  ImageController controller,
) {
  final typeString = jsonMap['type'] as String;
  final type = LayerType.fromValue(typeString);
  final nextJson = jsonMap['next'] as Map<String, dynamic>?;

  final ImageLayer? nextLayer = nextJson != null
      ? buildLayerChainFromJson(nextJson, controller)
      : null;

  switch (type) {
    case LayerType.solidBackground:
      return SolidBackgroundLayer.fromJson(jsonMap, nextLayer);
    case LayerType.gradientBackground:
      return GradientBackgroundLayer.fromJson(jsonMap, nextLayer);
    case LayerType.imageBackground:
      return ImageBackgroundLayer.fromJson(jsonMap, nextLayer);
    case LayerType.blurOverlay:
      return BlurOverlayLayer.fromJson(jsonMap, nextLayer);
    case LayerType.translucentOverlay:
      return TranlucentOverlayLayer.fromJson(jsonMap, nextLayer);
    case LayerType.bubbleOverlay:
      return BubbleOverlayLayer.fromJson(jsonMap, nextLayer);
    case LayerType.frostedGlass:
      return FrostedGlassLayer.fromJson(jsonMap, nextLayer);
    case LayerType.padding:
      return PaddingLayer.fromJson(jsonMap, nextLayer);
    case LayerType.pageCounter:
      return PageCounterLayer.fromJson(jsonMap, nextLayer, controller);
    case LayerType.text:
      return TextLayer.fromJson(jsonMap, controller);
    case null:
      throw Exception('Unknown layer type: $typeString');
  }
}
