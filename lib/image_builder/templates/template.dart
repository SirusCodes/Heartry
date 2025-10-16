import 'package:flutter/material.dart';
import '../core/image_controller.dart';

import '../core/image_layer.dart';
import '../layers/background.dart';
import '../layers/frames.dart';
import '../layers/overlay.dart';
import '../layers/text.dart';
import '../layers/utils.dart';

abstract class Template {
  Template({
    required this.name,
  });

  ImageLayer getLayers(ImageController controller, int currentPage);
  final String name;

  Widget getIcon(BuildContext context);
}

class SolidBackgroundTemplate implements Template {
  @override
  ImageLayer getLayers(ImageController controller, int currentPage) {
    return SolidBackgroundLayer(
      nextLayer: PaddingLayer(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 50,
        ),
        nextLayer: TextLayer(
          controller: controller,
          currentPage: currentPage,
        ),
      ),
    );
  }

  @override
  String get name => 'Solid Background';

  @override
  Widget getIcon(BuildContext context) {
    return const Icon(Icons.circle);
  }
}

class GradientBackgroundTemplate implements Template {
  @override
  ImageLayer getLayers(ImageController controller, int currentPage) {
    return GradientBackgroundLayer(
      nextLayer: PaddingLayer(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 50,
        ),
        nextLayer: TextLayer(
          controller: controller,
          currentPage: currentPage,
        ),
      ),
    );
  }

  @override
  String get name => 'Gradient Background';

  @override
  Widget getIcon(BuildContext context) {
    return const Icon(Icons.gradient);
  }
}

class GradientBubbleOverlayTemplate implements Template {
  @override
  ImageLayer getLayers(ImageController controller, int currentPage) {
    return GradientBackgroundLayer(
      nextLayer: BubbleOverlayLayer(
        nextLayer: PaddingLayer(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 50,
          ),
          nextLayer: FrostedGlassLayer(
            nextLayer: PaddingLayer(
              padding: const EdgeInsets.all(16),
              nextLayer: TextLayer(
                controller: controller,
                currentPage: currentPage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  String get name => 'Gradient Bubble Overlay';

  @override
  Widget getIcon(BuildContext context) {
    return const Icon(Icons.bubble_chart);
  }
}

class SolidBubbleOverlayTemplate implements Template {
  @override
  ImageLayer getLayers(ImageController controller, int currentPage) {
    return SolidBackgroundLayer(
      nextLayer: BubbleOverlayLayer(
        nextLayer: PaddingLayer(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 50,
          ),
          nextLayer: FrostedGlassLayer(
            nextLayer: PaddingLayer(
              padding: const EdgeInsets.all(16),
              nextLayer: TextLayer(
                controller: controller,
                currentPage: currentPage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  String get name => 'Solid Bubble Overlay';

  @override
  Widget getIcon(BuildContext context) {
    return const Icon(Icons.bubble_chart_outlined);
  }
}
