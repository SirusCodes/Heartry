import 'package:flutter/widgets.dart';

import 'image_controller.dart';

abstract class ImageLayer {
  const ImageLayer({required this.nextLayer});

  final ImageLayer? nextLayer;

  Widget build(
    BuildContext context,
    ImageController controller,
    int currentPage,
  ) {
    if (nextLayer == null) {
      return const SizedBox.shrink();
    }

    return nextLayer!.build(context, controller, currentPage);
  }

  List<Widget> getEditingOptions(ImageController controller) {
    if (nextLayer == null) {
      return [];
    }

    return nextLayer!.getEditingOptions(controller);
  }

  EdgeInsets getPadding() {
    if (nextLayer == null) {
      return EdgeInsets.zero;
    }

    return nextLayer!.getPadding();
  }
}
