import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/contants.dart';

class TextSplittingService {
  TextSplittingService({
    required this.context,
    required this.constraints,
    required this.title,
    required this.poet,
    required this.poem,
    required this.contentPadding,
    required TextStyle textStyle,
  }) : _textStyle = DefaultTextStyle.of(context).style;

  final BuildContext context;
  final BoxConstraints constraints;
  final String? title;
  final String poet;
  final List<String> poem;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle _textStyle;

  List<List<String>> getPoemSeparated(double textScale) {
    final double spaceForPoemX =
        constraints.maxWidth - contentPadding.horizontal;

    // getting title height
    double titleHeight = 0;
    if (title != null && title!.isNotEmpty) {
      titleHeight = _calcTextSize(
        title!,
        TITLE_TEXT_SIZE,
        math.min(textScale, 1.2),
        spaceForPoemX,
        POEM_TITLE_MAX_LINES,
      ).height;

      titleHeight += POEM_SPACING;
    }

    // getting poet height
    double poetHeight = _calcTextSize(
      poet,
      POET_TEXT_SIZE,
      math.min(textScale, 1.2),
      spaceForPoemX,
      POET_NAME_MAX_LINES,
    ).height;
    poetHeight += POEM_SPACING;

    final double spaceForPoemY = constraints.maxHeight -
        contentPadding.vertical -
        titleHeight -
        poetHeight;

    final pages = _getPoemPages(
      availableHeight: spaceForPoemY,
      context: context,
      remainingLines: poem,
      pages: [[]],
      textScale: textScale,
      maxWidth: spaceForPoemX,
      spaceForPoemY: spaceForPoemY,
    );

    return pages.map(_removeEmptyStartAndEnds).toList();
  }

  List<String> _removeEmptyStartAndEnds(List<String> page) {
    if (page[0].isEmpty) {
      page.removeAt(0);
    }
    if (page[page.length - 1].isEmpty) {
      page.removeAt(page.length - 1);
    }

    return page;
  }

  List<List<String>> _getPoemPages({
    required BuildContext context,
    required List<String> remainingLines,
    required List<List<String>> pages,
    required double textScale,
    required double maxWidth,
    required double availableHeight,
    required double spaceForPoemY,
  }) {
    if (remainingLines.isEmpty) {
      return pages;
    }

    final line = remainingLines.first;
    final heightToSub = _calcTextSize(
      line,
      POEM_TEXT_SIZE,
      textScale,
      maxWidth,
    ).height;

    if (heightToSub > availableHeight) {
      // Split the line into two parts
      final (firstPart, remaining) = _splitLine(
        context,
        textScale,
        remainingLines.removeAt(0),
        maxWidth,
        availableHeight,
      );

      // Add the first part to the current page
      if (firstPart.isNotEmpty) {
        pages.last.add(firstPart);
      }

      // Add the remaining part back to the remaining lines
      if (remaining.isNotEmpty) {
        remainingLines.insert(0, remaining);
      }

      if (remainingLines.isNotEmpty) {
        // Create a new page as the current one is full
        return _getPoemPages(
          context: context,
          remainingLines: remainingLines,
          pages: [...pages, []],
          textScale: textScale,
          maxWidth: maxWidth,
          availableHeight: spaceForPoemY,
          spaceForPoemY: spaceForPoemY,
        );
      }
    }

    pages.last.add(line);
    // Return if no remaining lines
    if (remainingLines.isEmpty) {
      return pages;
    }
    // Recursively call the function with the remaining lines
    return _getPoemPages(
      context: context,
      remainingLines: remainingLines.sublist(1),
      pages: pages,
      textScale: textScale,
      maxWidth: maxWidth,
      availableHeight: availableHeight - heightToSub,
      spaceForPoemY: spaceForPoemY,
    );
  }

  (String line, String remaining) _splitLine(
    BuildContext context,
    double textScale,
    String line,
    double maxWidth,
    double availableHeight,
  ) {
    List<String> words = line.split(" ");
    String currentLine = "";

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      currentLine = "$currentLine $word";
      final testSize = _calcTextSize(
        currentLine,
        POEM_TEXT_SIZE,
        textScale,
        maxWidth,
      );

      if (testSize.height >= availableHeight) {
        return (words.sublist(0, i).join(" "), words.sublist(i).join(" "));
      }
    }

    return (line, "");
  }

  Size _calcTextSize(
    String text,
    double fontSize,
    double scale,
    double maxWidth, [
    int? maxLines,
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: _textStyle.copyWith(
          fontSize: fontSize,
          fontFamily: "Caveat",
        ),
      ),
      maxLines: maxLines,
      textScaler: TextScaler.linear(scale),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.size;
  }
}
