import 'dart:ui';

import 'package:flutter/material.dart';

import 'poem_image_text.dart';

class PoemImageCard extends StatelessWidget {
  const PoemImageCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          padding: const EdgeInsets.all(20),
          child: const PoemImageText(),
        ),
      ),
    );
  }
}
