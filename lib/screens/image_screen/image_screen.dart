import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import '../../providers/text_providers.dart';
import '../share_images_screen/share_images_screen.dart';
import 'widgets/image_bottom_app_bar.dart';
import 'widgets/image_color_handler.dart';
import 'widgets/image_text_hander.dart';
import 'widgets/poem_image_widget.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    Key key,
    @required this.poem,
    @required this.title,
    @required this.poet,
  }) : super(key: key);

  final String title, poet;

  final List<String> poem;

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ScreenshotController _screenshot = ScreenshotController();

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<String>> poemLines = [];

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
                  poemLines = _getPoemSeparated(
                    context,
                    constraints,
                    _textScale,
                  );

                  return Screenshot(
                    controller: _screenshot,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: poemLines.length,
                      itemBuilder: (context, index) => PoemImageWidget(
                        title: widget.title,
                        poem: poemLines[index],
                        page: index,
                        total: poemLines.length,
                        poet: widget.poet,
                      ),
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
        onDonePressed: () async {
          imageCache.clear();

          final List<String> images = [];

          _showProgressDialog(context);

          for (int pageIndex = 0; pageIndex < poemLines.length; pageIndex++) {
            _pageController.jumpToPage(pageIndex);
            final path = await _getImage(pageIndex);
            images.add(path);
          }

          Navigator.pop(context);

          _showShareTypeDialog(context, images);
        },
      ),
    );
  }

  Future _showShareTypeDialog(BuildContext context, List<String> images) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("How would you like to share?"),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 10,
        ),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Share.shareFiles(
                images,
                mimeTypes: List.generate(
                  poemLines.length,
                  (index) => "image/png",
                ),
              );
            },
            child: const Text("Share all"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShareImagesScreen(imagePaths: images),
              ),
            ),
            child: const Text("Share in parts"),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          child: Material(
            child: Center(
              heightFactor: 3,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getImage(int index) async {
    final externalStorage = await getExternalStorageDirectory();

    final path = join(
      externalStorage.path,
      "${widget.title}-$index.png",
    );

    final File imgFile = await _screenshot.capture(
      delay: const Duration(milliseconds: 50),
      path: path,
    );

    return imgFile.path;
  }

  List<List<String>> _getPoemSeparated(
    BuildContext context,
    BoxConstraints constraints,
    double _textScale,
  ) {
    final List<List<String>> poemLines = [];
    final List<String> poemLine = [];

    final _size = MediaQuery.of(context).size;

    // getting title height
    final _titleHeight =
        _calcTextSize(context, constraints, widget.title, 30, _textScale)
            .height;

    // getting poet height
    final _poetHeight =
        _calcTextSize(context, constraints, widget.poet, 18, _textScale).height;

    final double _availableHeight =
        _size.height - 200 - _titleHeight - _poetHeight;

    double _height = _availableHeight;

    // creating the size of the poem
    for (final line in widget.poem) {
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
