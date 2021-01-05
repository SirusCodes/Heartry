import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

import '../../providers/text_providers.dart';
import 'widgets/image_bottom_app_bar.dart';
import 'widgets/image_color_handler.dart';
import 'widgets/image_text_hander.dart';
import 'widgets/poem_image_widget.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key key,
    @required this.poem,
    @required this.title,
    @required this.poet,
  }) : super(key: key);

  final String title, poet;

  final List<String> poem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Consumer(
            builder: (context, watch, child) {
              final _textScale = watch(textSizeProvider).state;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final List<List<String>> poemLines = _getPoemSeparated(
                    context,
                    constraints,
                    _textScale,
                  );

                  return PageView.builder(
                    itemCount: poemLines.length,
                    itemBuilder: (context, index) => PoemImageWidget(
                      title: title,
                      poem: poemLines[index],
                      page: index,
                      total: poemLines.length,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ImageBottomAppBar(
        onTextPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (context) {
              return const ImageTextHandler();
            },
          );
        },
        onColorPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (context) {
              return const ImageColorHandler();
            },
          );
        },
        onDonePressed: () {},
      ),
    );
  }

  List<List<String>> _getPoemSeparated(
    BuildContext context,
    BoxConstraints constraints,
    double _textScale,
  ) {
    final List<List<String>> poemLines = [];
    final List<String> poemLine = [];

    final _size = MediaQuery.of(context).size;

    // subtracting title height
    final _titleHeight =
        _calcTextSize(context, constraints, title, 30, _textScale).height;

    // subtracting poet height
    final _poetHeight =
        _calcTextSize(context, constraints, poet, 18, _textScale).height;

    final double _availableHeight =
        _size.height - 200 - _titleHeight - _poetHeight;

    double _height = _availableHeight;

    // subtracting poem height
    for (final line in poem) {
      final double _heightToSub =
          _calcTextSize(context, constraints, line, 15, _textScale).height;

      _height -= _heightToSub;

      if (_height <= 0) {
        poemLines.add([...poemLine]);
        poemLine.clear();
        _height = _availableHeight - _heightToSub;
      }

      poemLine.add(line);
    }

    if (_height > 0) poemLines.add([...poemLine]);

    return poemLines;
  }

  Size _calcTextSize(
    BuildContext context,
    BoxConstraints constraints,
    String text,
    double fontSize,
    double scale,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      ),
      textScaleFactor: scale,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: constraints.maxWidth - 120);

    return painter.size;
  }
}
