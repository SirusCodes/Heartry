import 'package:flutter/material.dart';

import '../../../utils/contants.dart';

class TextSplittingService {
  static List<List<String>> getPoemSeparated({
    required BuildContext context,
    required BoxConstraints constraints,
    required double textScale,
    required List<String> poem,
    required String? title,
    required String? poet,
    required EdgeInsetsGeometry contentMargin,
  }) {
    final List<List<String>> poemLines = [];
    final List<String> poemLine = [];

    // getting title height
    final titleHeight = title != null && title.isNotEmpty
        ? _calcTextSize(
            context,
            constraints,
            title,
            TITLE_TEXT_SIZE,
            textScale <= 1.2 ? textScale : 1.2,
            contentMargin.horizontal,
            POEM_TITLE_MAX_LINES,
          ).height
        : 0;

    // getting poet height
    final poetHeight = poet != null && poet.isNotEmpty
        ? _calcTextSize(
            context,
            constraints,
            poet,
            POET_TEXT_SIZE,
            textScale <= 1.2 ? textScale : 1.2,
            contentMargin.horizontal,
            POET_NAME_MAX_LINES,
          ).height
        : 0;

    final double availableHeight = constraints.maxHeight -
        contentMargin.vertical -
        titleHeight -
        poetHeight;

    double height = availableHeight;

    for (final line in poem) {
      double heightToSub = _calcTextSize(
        context,
        constraints,
        line,
        POEM_TEXT_SIZE,
        textScale,
        contentMargin.horizontal,
      ).height;

      // If a single line is too tall to fit, split it into smaller lines
      if (heightToSub > availableHeight) {
        final words = line.split(' ');
        String current = '';
        for (final word in words) {
          final testLine = current.isEmpty ? word : '$current $word';
          final testHeight = _calcTextSize(
            context,
            constraints,
            testLine,
            POEM_TEXT_SIZE,
            textScale,
            contentMargin.horizontal,
          ).height;
          // If a single word is too long to fit, force it onto a new page
          if (testHeight > availableHeight && current.isEmpty) {
            poemLine.add(word);
            poemLines.add([...poemLine]);
            poemLine.clear();
            height = availableHeight;
            current = '';
            continue;
          }
          // If adding the word exceeds the page, start a new page
          if (testHeight > height && current.isNotEmpty) {
            poemLine.add(current);
            poemLines.add([...poemLine]);
            poemLine.clear();
            height = availableHeight;
            current = word;
          } else {
            current = current.isEmpty ? word : '$current $word';
          }
        }
        if (current.isNotEmpty) {
          final currentHeight = _calcTextSize(
            context,
            constraints,
            current,
            POEM_TEXT_SIZE,
            textScale,
            contentMargin.horizontal,
          ).height;
          if (currentHeight > height && poemLine.isNotEmpty) {
            poemLines.add([...poemLine]);
            poemLine.clear();
            height = availableHeight;
          }
          poemLine.add(current);
          height -= currentHeight;
        }
      } else {
        // Normal line
        if (heightToSub > height && poemLine.isNotEmpty) {
          poemLines.add([...poemLine]);
          poemLine.clear();
          height = availableHeight;
        }
        poemLine.add(line);
        height -= heightToSub;
      }

      if (height <= 0) {
        if (poemLine.isNotEmpty && poemLine[poemLine.length - 1].isEmpty)
          poemLine.removeLast();
        if (poemLine.isNotEmpty) poemLines.add([...poemLine]);
        poemLine.clear();
        height = availableHeight;
      }
    }

    if (poemLine.isNotEmpty) {
      poemLines.add([...poemLine]);
    } else if (poemLines.isEmpty && poem.isNotEmpty) {
      poemLines.add([...poem]);
    }

    return poemLines;
  }

  static Size _calcTextSize(
    BuildContext context,
    BoxConstraints constraints,
    String text,
    double fontSize,
    double scale,
    double horizontalMargin, [
    int? maxLines,
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: "Caveat",
        ),
      ),
      maxLines: maxLines,
      textScaler: TextScaler.linear(scale),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: constraints.maxWidth - horizontalMargin);

    return painter.size;
  }
}
