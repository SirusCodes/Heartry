import 'package:flutter/material.dart';

class PoemImageText extends StatelessWidget {
  const PoemImageText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          "Title",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        Text(
          "Poem\n" * 20,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        const Text(
          "~Poet",
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
