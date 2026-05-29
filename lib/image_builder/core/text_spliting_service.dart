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
        text: title!,
        fontSize: TITLE_TEXT_SIZE,
        scale: math.min(textScale, 1.2),
        maxWidth: spaceForPoemX,
        fontFamily: _textStyle.fontFamily!,
        maxLines: POEM_TITLE_MAX_LINES,
      ).height;

      titleHeight += POEM_SPACING;
    }

    // getting poet height
    double poetHeight = _calcTextSize(
      text: poet,
      fontSize: POET_TEXT_SIZE,
      scale: math.min(textScale, 1.2),
      maxWidth: spaceForPoemX,
      fontFamily: _textStyle.fontFamily!,
      maxLines: POET_NAME_MAX_LINES,
    ).height;
    poetHeight += POEM_SPACING;

    final double spaceForPoemY =
        constraints.maxHeight -
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
    if (page.isNotEmpty && page[0].isEmpty) {
      page.removeAt(0);
    }
    if (page.isNotEmpty && page[page.length - 1].isEmpty) {
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

    // Find the maximum number of whole lines we can fit in availableHeight
    int k = 0;
    double currentHeight = 0;
    for (int i = 0; i < remainingLines.length; i++) {
      final line = remainingLines[i];
      final height = _calcTextSize(
        text: line,
        fontSize: POEM_TEXT_SIZE,
        scale: textScale,
        maxWidth: maxWidth,
        fontFamily: _textStyle.fontFamily!,
      ).height;

      if (currentHeight + height <= availableHeight) {
        currentHeight += height;
        k = i + 1;
      } else {
        break;
      }
    }

    // If all remaining lines fit on the current page, add them and return
    if (k == remainingLines.length) {
      pages.last.addAll(remainingLines);
      return pages;
    }

    // If at least one whole line fits,
    // we try to split at a paragraph end or line end
    if (k > 0) {
      // Priority 1: Split at paragraph ends (empty lines)
      int? paragraphSplitIndex;
      for (int i = k - 1; i >= 1; i--) {
        if (remainingLines[i].trim().isEmpty) {
          paragraphSplitIndex = i;
          break;
        }
      }

      if (paragraphSplitIndex != null) {
        pages.last.addAll(remainingLines.sublist(0, paragraphSplitIndex));
        return _getPoemPages(
          context: context,
          remainingLines: remainingLines.sublist(paragraphSplitIndex),
          pages: [...pages, []],
          textScale: textScale,
          maxWidth: maxWidth,
          availableHeight: spaceForPoemY,
          spaceForPoemY: spaceForPoemY,
        );
      }

      // Priority 2: Split at line ends (after the last whole line that fits)
      pages.last.addAll(remainingLines.sublist(0, k));
      return _getPoemPages(
        context: context,
        remainingLines: remainingLines.sublist(k),
        pages: [...pages, []],
        textScale: textScale,
        maxWidth: maxWidth,
        availableHeight: spaceForPoemY,
        spaceForPoemY: spaceForPoemY,
      );
    }

    // Priority 3: Split the first line itself
    // since not even one whole line fits
    final lineToSplit = remainingLines.first;
    final (firstPart, remaining) = _splitLine(
      context,
      textScale,
      lineToSplit,
      maxWidth,
      availableHeight,
    );

    if (firstPart.isEmpty && availableHeight == spaceForPoemY) {
      // Safety guard: if we are on a fresh page and not even the first word
      // fits, we must force-add at least the first word to make progress
      // and avoid infinite recursion.
      final firstWord = lineToSplit.split(" ").first;
      final rest = lineToSplit.substring(
        math.min(firstWord.length + 1, lineToSplit.length),
      );
      pages.last.add(firstWord);

      final nextRemaining = <String>[];
      if (rest.isNotEmpty) {
        nextRemaining.add(rest);
      }
      nextRemaining.addAll(remainingLines.sublist(1));

      if (nextRemaining.isEmpty) {
        return pages;
      }
      return _getPoemPages(
        context: context,
        remainingLines: nextRemaining,
        pages: [...pages, []],
        textScale: textScale,
        maxWidth: maxWidth,
        availableHeight: spaceForPoemY,
        spaceForPoemY: spaceForPoemY,
      );
    }

    if (firstPart.isNotEmpty) {
      pages.last.add(firstPart);
    }

    final nextRemaining = <String>[];
    if (remaining.isNotEmpty) {
      nextRemaining.add(remaining);
    }
    nextRemaining.addAll(remainingLines.sublist(1));

    if (nextRemaining.isNotEmpty) {
      return _getPoemPages(
        context: context,
        remainingLines: nextRemaining,
        pages: [...pages, []],
        textScale: textScale,
        maxWidth: maxWidth,
        availableHeight: spaceForPoemY,
        spaceForPoemY: spaceForPoemY,
      );
    }

    return pages;
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
        text: currentLine,
        fontSize: POEM_TEXT_SIZE,
        scale: textScale,
        maxWidth: maxWidth,
        fontFamily: _textStyle.fontFamily!,
      );

      if (testSize.height >= availableHeight) {
        return (words.sublist(0, i).join(" "), words.sublist(i).join(" "));
      }
    }

    return (line, "");
  }

  Size _calcTextSize({
    required String text,
    required double fontSize,
    required double scale,
    required double maxWidth,
    required String fontFamily,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: _textStyle.copyWith(fontSize: fontSize, fontFamily: fontFamily),
      ),
      maxLines: maxLines,
      textScaler: TextScaler.linear(scale),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.size;
  }
}
