import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

import '../../providers/text_providers.dart';
import 'widgets/image_bottom_app_bar.dart';
import 'widgets/image_color_handler.dart';
import 'widgets/image_text_hander.dart';
import 'widgets/poem_image_widget.dart';

class ImageScreen extends ConsumerWidget {
  const ImageScreen({
    Key key,
    @required this.poem,
    @required this.title,
    @required this.poet,
  }) : super(key: key);

  final String title, poet;

  final List<String> poem;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _textScale = watch(textSizeProvider).state;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final List<String> poemLines = [];

              final _size = MediaQuery.of(context).size;
              double _height = _size.height - 200;

              // subtracting title height
              _height -=
                  _calcTextSize(context, constraints, title, 30, _textScale)
                      .height;

              // subtracting poet height
              _height -=
                  _calcTextSize(context, constraints, poet, 18, _textScale)
                      .height;

              // subtracting poem height
              for (final line in poem) {
                _height -=
                    _calcTextSize(context, constraints, line, 15, _textScale)
                        .height;
                if (_height <= 0) break;

                poemLines.add(line);
              }

              return PoemImageWidget(poem: poemLines);
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
