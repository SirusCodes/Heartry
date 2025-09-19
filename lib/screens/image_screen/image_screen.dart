import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../image_builder/core/image_controller.dart';
import '../image_builder/layers/background.dart';
import '../image_builder/layers/frames.dart';
import '../image_builder/layers/overlay.dart';
import '../image_builder/layers/text.dart';
import '../image_builder/layers/utils.dart';
import '../share_images_screen/share_images_screen.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    super.key,
    required this.title,
    required this.poem,
    required this.poet,
  });

  final String? title, poet;
  final String poem;

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

  @override
  Widget build(BuildContext context) {
    final imageLayers = GradientBackgroundLayer(
      nextLayer: BubbleOverlayLayer(
        nextLayer: PageCounterLayer(
          nextLayer: PaddingLayer(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 50,
            ),
            nextLayer: FrostedGlassLayer(
              nextLayer: PaddingLayer(
                padding: const EdgeInsets.all(16.0),
                nextLayer: TextLayer(),
              ),
            ),
          ),
        ),
      ),
    );

    final colorScheme = Theme.of(context).colorScheme;
    final imageController = ImageController(
      context: context,
      title: widget.title,
      author: widget.poet ?? "",
      poem: widget.poem,
      padding: imageLayers.getPadding(),
      textStyle: TextStyle(
        color: colorScheme.onPrimary,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () => onSharePressed(
              context,
              imageController.poemSeparated.length,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Center(
            child: Screenshot(
              controller: _screenshot,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  imageController.constraints = constraints;

                  return ListenableBuilder(
                    listenable: imageController,
                    builder: (context, child) => PageView.builder(
                      controller: _pageController,
                      itemCount: imageController.poemSeparated.length,
                      itemBuilder: (context, index) => imageLayers.build(
                        context,
                        imageController,
                        index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: imageLayers.getEditingOptions(imageController),
        ),
      ),
    );
  }

  void onSharePressed(BuildContext context, int numberOfPages) async {
    final navigator = Navigator.of(context);

    imageCache.clear();

    final List<String> images = [];

    _showProgressDialog(context);

    for (int pageIndex = 0; pageIndex < numberOfPages; pageIndex++) {
      _pageController.jumpToPage(pageIndex);
      final image = await _getImage(pageIndex);
      images.add(image);
    }

    navigator.pop();

    if (images.length == 1) {
      await _shareAll(images);
      return;
    }

    if (!context.mounted) return;

    _showShareTypeDialog(context, images);
  }

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
                builder: (_) => ShareImagesScreen(images: images),
              ),
            ),
            child: const Text("Share in parts"),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAll(List<String> images) async {
    await SharePlus.instance.share(ShareParams(
      text: "Made using Heartry 💜\n"
          "Download at https://play.google.com/store/apps/details?id=com.darshan.heartry",
      files: images.map((img) => XFile(img, mimeType: "image/png")).toList(),
    ));
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

    final time = DateTime.now().toIso8601String();

    final path = join(
      tmpDir.path,
      "${widget.title}-$time-$index.png",
    );

    final imgBytes = await _screenshot.capture(
      pixelRatio: 3,
      delay: const Duration(milliseconds: 50),
    );

    final imgFile = File(path)..writeAsBytes(imgBytes!);

    return imgFile.path;
  }
}
