import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/text_providers.dart';
import '../../../utils/contants.dart';

class PoemImageText extends ConsumerWidget {
  const PoemImageText({
    super.key,
    required this.title,
    required this.poem,
    required this.poet,
  });

  final List<String> poem;
  final String title, poet;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(textSizeProvider);
    final color = ref.watch(textColorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(math.min(scale, 1.2)),
          style: TextStyle(
            fontSize: TITLE_TEXT_SIZE,
            color: color,
            fontFamily: "Caveat",
            fontWeight: FontWeight.bold,
          ),
          maxLines: POEM_TITLE_MAX_LINES,
          overflow: TextOverflow.ellipsis,
        ),
        ...poem.map(
          (e) => Text(
            e,
            textScaler: TextScaler.linear(scale),
            style: TextStyle(
              fontSize: POEM_TEXT_SIZE,
              color: color,
              fontFamily: "Caveat",
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "-$poet",
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(math.min(scale, 1.2)),
          style: TextStyle(
            fontSize: POET_TEXT_SIZE,
            color: color,
            fontFamily: "Caveat",
          ),
          maxLines: POET_NAME_MAX_LINES,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
