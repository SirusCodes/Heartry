import 'dart:ui';

import 'package:flutter/material.dart';

import 'poem_image_text.dart';

class PoemImageCard extends StatelessWidget {
  const PoemImageCard({Key key, this.poem, this.title}) : super(key: key);

  final List<String> poem;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.topLeft,
                begin: Alignment.bottomRight,
                colors: <Color>[
                  Colors.white.withOpacity(.2),
                  Colors.white.withOpacity(.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(30),
            child: PoemImageText(
              poem: poem,
              title: title,
            ),
          ),
        ),
      ),
    );
  }
}
