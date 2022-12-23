import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import '../../providers/text_providers.dart';
import '../../utils/contants.dart';
import '../share_images_screen/share_images_screen.dart';
import 'widgets/image_bottom_app_bar.dart';
import 'widgets/image_color_handler.dart';
import 'widgets/image_text_hander.dart';
import 'widgets/poem_image_widget.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    Key? key,
    required this.poem,
    required this.title,
    required this.poet,
  }) : super(key: key);

  final String? title, poet;

  final List<String> poem;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
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
              final textScale = watch(textSizeProvider).state;
              return LayoutBuilder(
                builder: (context, constraints) {
                  poemLines = _getPoemSeparated(
                    context,
                    constraints,
                    textScale,
                  );

                  return Screenshot<void>(
                    controller: _screenshot,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: poemLines.length,
                      itemBuilder: (context, index) => PoemImageWidget(
                        title: widget.title!,
                        poem: poemLines[index],
                        page: index,
                        total: poemLines.length,
                        poet: widget.poet!,
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
          showModalBottomSheet<void>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (context) {
              return const ImageTextHandler();
            },
          );
        },
        onColorPressed: () {
          showModalBottomSheet<void>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (context) {
              return const ImageColorHandler();
            },
          );
        },
        onDonePressed: () async {
          // TODO: Once save to gallery is implemented
          // if (!(await _isPermGranted(context))) return;

          final navigator = Navigator.of(context);

          imageCache.clear();

          final List<String> images = [];

          _showProgressDialog(context);

          for (int pageIndex = 0; pageIndex < poemLines.length; pageIndex++) {
            _pageController.jumpToPage(pageIndex);
            final path = await _getImage(pageIndex + 1);
            images.add(path);
          }

          navigator.pop();

          if (images.length == 1) {
            await _shareAll(images);
            return;
          }

          if (!mounted) return;

          _showShareTypeDialog(context, images);
        },
      ),
    );
  }

/*
  TODO: Once save to gallery is implemented
  Future<bool> _isPermGranted(BuildContext context) async {
    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    bool _isSettingsOpened = false;

    if (status.isPermanentlyDenied) _isSettingsOpened = await openAppSettings();

    if (!_isSettingsOpened)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please allow to store images"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
        ),
      );

    return false;
  }
*/

  Future _showShareTypeDialog(BuildContext context, List<String> images) {
    return showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("How would you like to share?"),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 10,
        ),
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareAll(images);
            },
            child: const Text("Share all"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push<void>(
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

  Future<void> _shareAll(List<String> images) async {
    await Share.shareFiles(
      images,
      mimeTypes: List.generate(
        poemLines.length,
        (index) => "image/png",
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog<void>(
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
    final tmpDir = await getTemporaryDirectory();

    final path = join(
      tmpDir.path,
      "${widget.title}-$index.png",
    );

    final imgBytes = await _screenshot.capture(
      pixelRatio: 3,
      delay: const Duration(milliseconds: 50),
    );

    final imgFile = File(path)..writeAsBytes(imgBytes!);

    return imgFile.path;
  }

  List<List<String>> _getPoemSeparated(
    BuildContext context,
    BoxConstraints constraints,
    double textScale,
  ) {
    final List<List<String>> poemLines = [];
    final List<String> poemLine = [];

    final size = MediaQuery.of(context).size;

    // getting title height
    final titleHeight = _calcTextSize(
      context,
      constraints,
      widget.title!,
      TITLE_TEXT_SIZE,
      textScale,
    ).height;

    // getting poet height
    final poetHeight = _calcTextSize(
      context,
      constraints,
      widget.poet!,
      POET_TEXT_SIZE,
      textScale,
    ).height;

    final double availableHeight = size.height - 200 - titleHeight - poetHeight;

    double height = availableHeight;

    // creating the size of the poem
    for (final line in widget.poem) {
      final double heightToSub = _calcTextSize(
        context,
        constraints,
        line,
        POEM_TEXT_SIZE,
        textScale,
      ).height;

      height -= heightToSub;

      if (height <= 0) {
        poemLines.add([...poemLine]);
        poemLine.clear();
        height = availableHeight - heightToSub;
      }

      poemLine.add(line);
    }

    if (height > 0) poemLines.add([...poemLine]);

    return poemLines;
  }

  Size _calcTextSize(
    BuildContext context,
    BoxConstraints constraints,
    String /*!*/ text,
    double fontSize,
    double scale,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: "Caveat",
        ),
      ),
      textScaleFactor: scale,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: constraints.maxWidth - 120);

    return painter.size;
  }
}
