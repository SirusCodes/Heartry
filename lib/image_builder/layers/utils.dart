import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/image_controller.dart';
import '../core/image_layer.dart';

class PaddingLayer extends ImageLayer {
  const PaddingLayer({super.key, required this.padding, super.nextLayer});

  final EdgeInsets padding;

  @override
  EdgeInsets getPadding() {
    return padding + super.getPadding();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: padding,
      child: nextLayer!.build(context),
    );
  }
}

class PageCounterLayer extends ImageLayer {
  const PageCounterLayer({
    super.key,
    super.nextLayer,
    required this.controller,
    required this.currentPage,
  });

  final ImageController controller;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final total = controller.poemSeparated.length;
    return Stack(
      children: [
        if (total > 1)
          Positioned(
            top: 20,
            right: 20,
            child: Consumer(
              builder: (context, ref, child) {
                return Text(
                  "${currentPage + 1}/$total",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: .5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        nextLayer!.build(context),
      ],
    );
  }
}
