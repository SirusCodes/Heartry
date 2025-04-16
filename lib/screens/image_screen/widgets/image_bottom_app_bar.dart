import 'package:flutter/material.dart';

class ImageBottomAppBar extends StatelessWidget {
  const ImageBottomAppBar({
    super.key,
    required this.onTextPressed,
    required this.onDonePressed,
    required this.onColorPressed,
  });

  final VoidCallback onColorPressed, onTextPressed, onDonePressed;
  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (isIOS)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: onTextPressed,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: onColorPressed,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: onDonePressed,
          )
        ],
      ),
    );
  }
}
