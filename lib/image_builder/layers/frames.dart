import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/image_layer.dart';

class FrostedGlassLayer extends ImageLayer {
  const FrostedGlassLayer({super.key, super.nextLayer});

  @override
  Widget build(BuildContext context) {
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
          child: nextLayer!.build(context),
        ),
      ),
    );
  }
}
