import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../utils/contants.dart';

class PoemImageText extends StatelessWidget {
  const PoemImageText({
    super.key,
    required this.title,
    required this.poem,
    required this.poet,
    required this.color,
    required this.scale,
  });

  final List<String> poem;
  final String? title, poet;

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PoemTextPainter(
        poem: poem,
        title: title,
        poet: poet,
        scale: scale,
        color: color,
      ),
      child: SizedBox.expand(),
    );
  }
}

class PoemTextPainter extends CustomPainter {
  final List<String> poem;
  final String? title, poet;
  final double scale;
  final Color color;

  PoemTextPainter({
    required this.poem,
    required this.title,
    required this.poet,
    required this.scale,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxWidth = size.width;
    double totalHeight = 0;

    // Build once
    final titlePainter = (title != null && title!.isNotEmpty) //
        ? _buildTitle(maxWidth)
        : null;
    final paragraph = _buildParagraph(maxWidth);
    final poetPainter = _buildPoet(maxWidth);

    // Calculate heights
    double titleHeight = 0;
    if (titlePainter != null) {
      titleHeight = titlePainter.height + POEM_SPACING;
    }
    double poemHeight = paragraph.height;
    double poetHeight = poetPainter.height + POEM_SPACING;

    totalHeight = titleHeight + poemHeight + poetHeight;

    double currentY = (size.height - totalHeight) / 2;

    if (titlePainter != null) {
      titlePainter.paint(
        canvas,
        Offset((maxWidth - titlePainter.width) / 2, currentY),
      );
      currentY += titlePainter.height + POEM_SPACING;
    }

    canvas.drawParagraph(paragraph, Offset(0, currentY));
    currentY += paragraph.height;

    currentY += POEM_SPACING;
    poetPainter.paint(
      canvas,
      Offset((maxWidth - poetPainter.width) / 2, currentY),
    );
  }

  TextPainter _buildTitle(double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: TITLE_TEXT_SIZE,
          fontFamily: "Caveat",
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
          color: color,
        ),
      ),
      maxLines: POEM_TITLE_MAX_LINES,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(scale).clamp(
        minScaleFactor: 1,
        maxScaleFactor: 1.2,
      ),
    );

    painter.layout(maxWidth: maxWidth);
    return painter;
  }

  TextPainter _buildPoet(double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        text: "-$poet",
        style: TextStyle(
          fontSize: POET_TEXT_SIZE,
          fontFamily: "Caveat",
          overflow: TextOverflow.ellipsis,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: POET_NAME_MAX_LINES,
      textScaler: TextScaler.linear(scale).clamp(
        minScaleFactor: 1,
        maxScaleFactor: 1.2,
      ),
    );

    painter.layout(maxWidth: maxWidth);
    return painter;
  }

  ui.Paragraph _buildParagraph(double maxWidth) {
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontFamily: "Caveat",
        fontSize: POEM_TEXT_SIZE * scale,
      ),
    );

    paragraphBuilder
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(poem.join("\n"));

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  @override
  bool shouldRepaint(PoemTextPainter oldDelegate) {
    return oldDelegate.poem != poem ||
        oldDelegate.title != title ||
        oldDelegate.poet != poet ||
        oldDelegate.scale != scale ||
        oldDelegate.color != color;
  }

  @override
  bool shouldRebuildSemantics(PoemTextPainter oldDelegate) => false;
}
