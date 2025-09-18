import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:heartry/screens/image_builder/core/image_controller.dart';

import '../core/image_layer.dart';

class FrostedGlassLayer extends ImageLayer {
  FrostedGlassLayer({super.nextLayer});

  @override
  Widget build(
    BuildContext context,
    ImageController controller,
    int currentPage,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.topLeft,
              begin: Alignment.bottomRight,
              colors: <Color>[
                Colors.white.withValues(alpha: .2),
                Colors.white.withValues(alpha: .05),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: super.build(
            context,
            controller,
            currentPage,
          ),
        ),
      ),
    );
  }
}
