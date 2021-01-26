import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/database/config.dart';
import 'package:heartry/init_get_it.dart';

import '../../../providers/color_gradient_provider.dart';
import '../../../providers/text_providers.dart';
import 'poem_image_card.dart';

class PoemImageWidget extends StatelessWidget {
  PoemImageWidget({
    Key key,
    @required this.title,
    @required this.poem,
    @required this.page,
    @required this.total,
    @required this.poet,
  }) : super(key: key);
  final List<String> poem;
  final int page, total;
  final String title, poet;

  final _imagePath = locator<Config>().profile;

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
              if (total > 1)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Consumer(
                    builder: (context, watch, child) {
                      final color = watch(textColorProvider).state;

                      return Text(
                        "${page + 1}/$total",
                        style: TextStyle(
                          fontSize: 17,
                          color: color,
                        ),
                      );
                    },
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
              if (_imagePath != null)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(File(_imagePath)),
                  ),
                ),
              Center(
                child: PoemImageCard(
                  poem: poem,
                  title: title,
                  poet: poet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
