import 'package:flutter/material.dart';

class ImageBottomAppBar extends StatelessWidget {
  const ImageBottomAppBar({
    Key key,
    @required this.onTextPressed,
    @required this.onColorPressed,
    @required this.onDonePressed,
  }) : super(key: key);

  final VoidCallback onTextPressed, onColorPressed, onDonePressed;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.check),
          )
        ],
      ),
    );
  }
}
