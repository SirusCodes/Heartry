import 'package:flutter/material.dart';

class ImageColorInvert extends StatelessWidget {
  const ImageColorInvert({
    Key? key,
    required this.image,
    this.invert = false,
  }) : super(key: key);

  final Image image;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    return invert
        ? ColorFiltered(
            colorFilter: const ColorFilter.matrix(
              [
                -1, 0, 0, 0, 255, //
                0, -1, 0, 0, 255, //
                0, 0, -1, 0, 255, //
                0, 0, 0, 1, 0, //
              ],
            ),
            child: image,
          )
        : image;
  }
}
