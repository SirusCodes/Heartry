import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/image_builder/core/image_controller.dart';
import 'package:heartry/image_builder/core/image_layer.dart';
import 'package:heartry/image_builder/templates/template.dart';

void main() {
  testWidgets('Recursive serialization and reconstruction works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final controller = ImageController(
              context: context,
              title: "My Title",
              author: "My Poet",
              poem: "Line 1\nLine 2",
            );

            final solidJson = {
              'type': 'solid_background',
              'color': 4284613234,
              'next': {
                'type': 'page_counter',
                'next': {
                  'type': 'padding',
                  'horizontal': 40.0,
                  'vertical': 50.0,
                  'next': {'type': 'text'},
                },
              },
            };

            final layerChain = buildLayerChainFromJson(solidJson, controller);
            expect(layerChain, isNotNull);

            final serialized = layerChain.toJson();
            expect(serialized, isNotNull);
            expect(serialized!['type'], 'solid_background');
            expect(serialized['color'], 4284613234);
            expect(serialized['next']['type'], 'page_counter');
            expect(serialized['next']['next']['type'], 'padding');
            expect(serialized['next']['next']['horizontal'], 40.0);
            expect(serialized['next']['next']['vertical'], 50.0);
            expect(serialized['next']['next']['next']['type'], 'text');

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('Layer traversal finds image background by runtime type', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final controller = ImageController(
              context: context,
              title: 'My Title',
              author: 'My Poet',
              poem: 'Line 1\nLine 2',
            );

            final imageJson = {
              'type': 'image_background',
              'image_base64': 'encoded-image',
              'next': {
                'type': 'page_counter',
                'next': {
                  'type': 'padding',
                  'horizontal': 40.0,
                  'vertical': 50.0,
                  'next': {'type': 'text'},
                },
              },
            };

            final layerChain = buildLayerChainFromJson(imageJson, controller);

            expect(layerChain.findLayer<ImageBackgroundLayer>(), isNotNull);

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets(
    'Updating image background value using type mutates target layer and serializes correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final controller = ImageController(
                context: context,
                title: 'My Title',
                author: 'My Poet',
                poem: 'Line 1\nLine 2',
              );

              final imageJson = {
                'type': 'image_background',
                'image_base64': 'encoded-image',
                'next': {'type': 'text'},
              };

              final layerChain = buildLayerChainFromJson(imageJson, controller);
              final imageLayer = layerChain.findLayer<ImageBackgroundLayer>();
              expect(imageLayer, isNotNull);
              expect(imageLayer!.imageBase64.value, 'encoded-image');

              // Mutate using modern layers
              imageLayer.imageBase64.value = 'new-encoded-image';

              final serialized = layerChain.toJson();
              expect(serialized, isNotNull);
              expect(serialized!['image_base64'], 'new-encoded-image');

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  );
}
