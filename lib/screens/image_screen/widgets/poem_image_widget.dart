import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/config.dart';
import '../../../providers/color_gradient_provider.dart';
import 'poem_image_card.dart';

class PoemImageWidget extends StatelessWidget {
  const PoemImageWidget({
    super.key,
    required this.title,
    required this.poem,
    required this.page,
    required this.total,
    required this.poet,
  });

  final List<String> poem;
  final int page, total;
  final String title, poet;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
              Consumer(
                builder: (context, ref, child) {
                  final gradientList =
                      ref.watch(colorGradientListProvider(primaryColor));

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientList,
                      ),
                    ),
                  );
                },
              ),
              if (total > 1)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return Text(
                        "${page + 1}/$total",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
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
              Center(
                child: PoemImageCard(
                  poem: poem,
                  title: title,
                  poet: poet,
                ),
              ),
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
