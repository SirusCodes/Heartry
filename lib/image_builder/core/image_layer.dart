import 'package:flutter/widgets.dart';

abstract class ImageLayer extends StatelessWidget {
  const ImageLayer({
    super.key,
    required this.nextLayer,
  });

  final ImageLayer? nextLayer;

  List<Widget> getEditingOptions(BuildContext context) {
    if (nextLayer == null) {
      return <Widget>[];
    }

    return nextLayer!.getEditingOptions(context);
  }

  EdgeInsets getPadding() {
    if (nextLayer == null) {
      return EdgeInsets.zero;
    }

    return nextLayer!.getPadding();
  }

  void dispose() {
    nextLayer?.dispose();
  }
}
