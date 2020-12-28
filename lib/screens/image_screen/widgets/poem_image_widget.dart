import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/color_gradient_provider.dart';
import 'poem_image_card.dart';

class PoemImageWidget extends StatelessWidget {
  const PoemImageWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: SizedBox.expand(
        child: Theme(
          data: ThemeData(
            primaryColorLight: Colors.white.withOpacity(.3),
            primaryColorDark: Colors.white.withOpacity(.3),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Consumer(
                builder: (context, watch, child) {
                  final _gradientList = watch(colorGradientListProvider.state);

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradientList,
                      ),
                    ),
                  );
                },
              ),
              const Positioned(
                top: -30,
                left: -30,
                child: CircleAvatar(
                  radius: 80,
                ),
              ),
              const Positioned(
                top: 200,
                right: -10,
                child: CircleAvatar(
                  radius: 40,
                ),
              ),
              const Positioned(
                bottom: -30,
                left: 0,
                child: CircleAvatar(
                  radius: 75,
                ),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 50,
                ),
              ),
              const Positioned(
                bottom: 250,
                right: 110,
                child: CircleAvatar(
                  radius: 20,
                ),
              ),
              const Center(
                child: PoemImageCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
