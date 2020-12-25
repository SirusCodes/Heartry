import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:heartry/screens/image_screen/widgets/image_bottom_app_bar.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.deepPurple.shade600,
                            Colors.deepPurple.shade500,
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade200,
                          ],
                        ),
                      ),
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
                    const Positioned.fill(
                      top: 30.0,
                      bottom: 30.0,
                      left: 30.0,
                      right: 30.0,
                      child: PoemCard(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ImageBottomAppBar(
        onTextPressed: () {},
        onColorPressed: () {},
        onDonePressed: () {},
      ),
    );
  }
}

class PoemCard extends StatelessWidget {
  const PoemCard({
    Key key,
  }) : super(key: key);

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
          child: const PoemText(),
        ),
      ),
    );
  }
}

class PoemText extends StatelessWidget {
  const PoemText({
    Key key,
  }) : super(key: key);

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
