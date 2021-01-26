import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/text_providers.dart';

class PoemImageText extends ConsumerWidget {
  const PoemImageText({
    Key key,
    @required this.title,
    @required this.poem,
    @required this.poet,
  }) : super(key: key);

  final List<String> poem;
  final String title, poet;
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
          "-$poet",
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
