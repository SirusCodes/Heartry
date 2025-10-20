import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../image_builder/core/image_controller.dart';
import '../../image_builder/templates/template.dart';
import '../../image_builder/widgets/page_details.dart';
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

  Template selectedTemplate = SolidBackgroundTemplate();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final imageController = ImageController(
      context: context,
      title: widget.title,
      author: widget.poet ?? "",
      poem: widget.poem,
      textStyle: TextStyle(
        color: colorScheme.onPrimary,
      ),
    );

    final layer = selectedTemplate.getLayers(imageController);

    imageController.padding = layer.getPadding();

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
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
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
                    itemBuilder: (context, index) {
                      return PageDetails(
                        currentPage: index,
                        // ignore: invalid_use_of_protected_member
                        child: layer.build(context),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                tooltip: "Change Template",
                icon: const Icon(Symbols.stacks),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) => SizedBox(
                      height: 300,
                      child: _TemplateSelector(
                        selectedTemplate: selectedTemplate,
                        templates: [
                          SolidBackgroundTemplate(),
                          GradientBackgroundTemplate(),
                          GradientBubbleOverlayTemplate(),
                          SolidBubbleOverlayTemplate(),
                        ],
                        onTemplateSelected: (template) {
                          setState(() {
                            selectedTemplate = template;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            VerticalDivider(),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: layer
                    .getEditingOptions(context)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: e,
                      ),
                    )
                    .toList(),
              ),
            )
          ],
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

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({
    required this.templates,
    required this.onTemplateSelected,
    required this.selectedTemplate,
  });

  final Template selectedTemplate;
  final List<Template> templates;
  final ValueChanged<Template> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: templates.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = selectedTemplate.name == templates[index].name;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            tileColor: isSelected ? colorScheme.primary.withAlpha(30) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            leading: template.getIcon(context),
            title: Text(template.name),
            onTap: () {
              onTemplateSelected(template);
            },
          ),
        );
      },
    );
  }
}
