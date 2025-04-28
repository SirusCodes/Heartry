import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/text_providers.dart';
import '../share_images_screen/share_images_screen.dart';
import 'core/base_image_design.dart';
import 'core/text_spliting_service.dart';
import 'designs/gradient_design.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    super.key,
    required this.title,
    required this.poem,
    required this.poet,
  });

  final String? title, poet;
  final List<String> poem;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ScreenshotController _screenshot = ScreenshotController();

  final PageController _pageController = PageController();

  late final BaseImageDesign design = GradientDesign(
    title: widget.title,
    poem: widget.poem,
    poet: widget.poet,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<String>> poemPages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () => onSharePressed(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final textScale = ref.watch(textSizeProvider);

            return AspectRatio(
              aspectRatio: 9 / 16,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textSplittingService = TextSplittingService(
                    context: context,
                    constraints: constraints,
                    title: widget.title,
                    poet: widget.poet!,
                    poem: widget.poem,
                    contentMargin: design.getContentMargin(),
                    extraSpacing: design.extraSpacing(),
                  );

                  poemPages = textSplittingService.getPoemSeparated(textScale);

                  return Center(
                    child: Screenshot(
                      controller: _screenshot,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: poemPages.length,
                        itemBuilder: (context, index) => SizedBox.expand(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              design.buildBackground(context),
                              design.buildContent(context, poemPages[index]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: design.getCustomizationOptions(context),
        ),
      ),
    );
  }

  void onSharePressed(BuildContext context) async {
    final navigator = Navigator.of(context);

    imageCache.clear();

    final List<String> images = [];

    _showProgressDialog(context);

    for (int pageIndex = 0; pageIndex < poemPages.length; pageIndex++) {
      _pageController.jumpToPage(pageIndex);
      final path = await _getImage(pageIndex + 1);
      images.add(path);
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
    await Share.shareXFiles(
      images.map((path) => XFile(path, mimeType: "image/png")).toList(),
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
      "${design.title}-$index.png",
    );

    final imgBytes = await _screenshot.capture(
      pixelRatio: 3,
      delay: const Duration(milliseconds: 50),
    );

    final imgFile = File(path)..writeAsBytes(imgBytes!);

    return imgFile.path;
  }
}
