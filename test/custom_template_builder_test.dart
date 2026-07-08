import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/image_builder/core/image_controller.dart';
import 'package:heartry/image_builder/core/image_layer.dart';
import 'package:heartry/screens/image_screen/custom_template_builder.dart';

Map<String, dynamic> buildLegacyTemplateJson({
  required String backgroundType,
  String? imageBase64,
  required String overlayType,
  required String frameType,
  required double outerPaddingH,
  required double outerPaddingV,
  required double innerPaddingH,
  required double innerPaddingV,
}) {
  Map<String, dynamic> current = {'type': 'text'};

  if (frameType == 'frosted_glass') {
    current = {
      'type': 'padding',
      'horizontal': innerPaddingH,
      'vertical': innerPaddingV,
      'next': current,
    };
    current = {'type': 'frosted_glass', 'next': current};
  }

  current = {
    'type': 'padding',
    'horizontal': outerPaddingH,
    'vertical': outerPaddingV,
    'next': current,
  };

  current = {'type': 'page_counter', 'next': current};

  if (overlayType == 'bubble_overlay') {
    current = {'type': 'bubble_overlay', 'next': current};
  } else if (overlayType == 'blur_overlay') {
    current = {'type': 'blur_overlay', 'blur': 5.0, 'next': current};
  } else if (overlayType == 'translucent_overlay') {
    current = {
      'type': 'translucent_overlay',
      'color': 4294967295,
      'opacity': 0.2,
      'next': current,
    };
  } else if (overlayType == 'blur_translucent') {
    current = {
      'type': 'translucent_overlay',
      'color': 4294967295,
      'opacity': 0.2,
      'next': current,
    };
    current = {'type': 'blur_overlay', 'blur': 5.0, 'next': current};
  }

  current = {
    'type': backgroundType,
    if (backgroundType == 'solid_background') 'color': null,
    if (backgroundType == 'gradient_background') 'gradient': null,
    if (backgroundType == 'image_background') 'image_base64': imageBase64,
    'next': current,
  };

  return current;
}

void main() {
  testWidgets('layer-based serializer matches legacy default template JSON', (
    WidgetTester tester,
  ) async {
    late Map<String, dynamic> actual;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final controller = ImageController(
              context: context,
              title: 'My Title',
              author: 'My Poet',
              poem: Delta()..insert("Line 1\nLine 2"),
            );

            actual = buildCustomTemplateJson(
              const CustomTemplateLayerConfig(
                backgroundType: LayerType.solidBackground,
                overlayTypes: [],
                frameType: null,
                outerPaddingH: 40,
                outerPaddingV: 50,
                innerPaddingH: 16,
                innerPaddingV: 16,
              ),
              controller,
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      actual,
      buildLegacyTemplateJson(
        backgroundType: 'solid_background',
        overlayType: 'none',
        frameType: 'none',
        outerPaddingH: 40,
        outerPaddingV: 50,
        innerPaddingH: 16,
        innerPaddingV: 16,
      ),
    );
  });

  testWidgets('layer-based serializer matches legacy composed template JSON', (
    WidgetTester tester,
  ) async {
    late Map<String, dynamic> actual;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final controller = ImageController(
              context: context,
              title: 'My Title',
              author: 'My Poet',
              poem: Delta()..insert("Line 1\nLine 2"),
            );

            actual = buildCustomTemplateJson(
              const CustomTemplateLayerConfig(
                backgroundType: LayerType.imageBackground,
                imageBase64: 'encoded-image',
                overlayTypes: [
                  LayerType.translucentOverlay,
                  LayerType.blurOverlay,
                ],
                frameType: LayerType.frostedGlass,
                outerPaddingH: 24,
                outerPaddingV: 32,
                innerPaddingH: 12,
                innerPaddingV: 18,
              ),
              controller,
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      actual,
      buildLegacyTemplateJson(
        backgroundType: 'image_background',
        imageBase64: 'encoded-image',
        overlayType: 'blur_translucent',
        frameType: 'frosted_glass',
        outerPaddingH: 24,
        outerPaddingV: 32,
        innerPaddingH: 12,
        innerPaddingV: 18,
      ),
    );
  });
}
