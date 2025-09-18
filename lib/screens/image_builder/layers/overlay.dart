import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/config.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class BubbleOverlayLayer extends ImageLayer {
  BubbleOverlayLayer({super.nextLayer});

  @override
  Widget build(
    BuildContext context,
    ImageController controller,
    int currentPage,
  ) {
    return _BubbleOverlayWidget(
      child: super.build(
        context,
        controller,
        currentPage,
      ),
    );
  }
}

class _BubbleOverlayWidget extends StatelessWidget {
  const _BubbleOverlayWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: SizedBox.expand(
        child: Theme(
          data: ThemeData(
            primaryColorLight: Colors.white.withValues(alpha: .3),
            primaryColorDark: Colors.white.withValues(alpha: .3),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned(
                top: -30,
                left: -30,
                child: CircleAvatar(radius: 80),
              ),
              const Positioned(
                top: 200,
                right: -10,
                child: CircleAvatar(radius: 40),
              ),
              const Positioned(
                bottom: -30,
                left: 0,
                child: CircleAvatar(radius: 75),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(radius: 50),
              ),
              const Positioned(
                bottom: 250,
                right: 110,
                child: CircleAvatar(radius: 20),
              ),
              Center(child: child),
              Consumer(
                builder: (context, ref, child) {
                  final config = ref.watch(configProvider);

                  return config.maybeWhen(
                    data: (data) {
                      if (data.profile != null)
                        return Positioned(
                          bottom: 20,
                          right: 20,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: FileImage(File(data.profile!)),
                          ),
                        );

                      return const SizedBox.shrink();
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
