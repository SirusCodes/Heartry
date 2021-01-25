import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/config.dart';
import '../../../init_get_it.dart';
import '../../../providers/text_providers.dart';

class PoemImageText extends ConsumerWidget {
  PoemImageText({Key key, this.title, this.poem}) : super(key: key);

  final List<String> poem;
  final String title;

  final name = locator<Config>().name;
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _scale = watch(textSizeProvider).state;
    final color = watch(textColorProvider).state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          textScaleFactor: _scale,
          style: TextStyle(
            fontSize: 30,
            color: color,
          ),
        ),
        ...poem.map(
          (e) => Text(
            e,
            textScaleFactor: _scale,
            style: TextStyle(
              fontSize: 15,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "-$name",
          textAlign: TextAlign.center,
          textScaleFactor: _scale,
          style: TextStyle(
            fontSize: 17,
            color: color,
          ),
        ),
      ],
    );
  }
}
