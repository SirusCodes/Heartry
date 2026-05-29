import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../image_builder/core/image_controller.dart';
import '../../image_builder/core/image_layer.dart';
import '../../image_builder/templates/template.dart';
import '../../image_builder/widgets/editing_option.dart';
import '../../image_builder/widgets/page_details.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../widgets/save_template_dialog.dart';
import 'custom_template_creator.dart';
import '../share_images_screen/share_images_screen.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    super.key,
    required this.title,
    required this.poem,
    required this.poet,
  });

  static const String routePath = '/image';

  final String? title, poet;
  final String poem;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ScreenshotController _screenshot = ScreenshotController();
  final PageController _pageController = PageController();

  Template? selectedTemplate;
  List<Template> _templates = [];
  bool _isLoadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final dbModels = await locator<Database>().getTemplates();
      setState(() {
        _templates = dbModels
            .map(
              (t) => Template(
                id: t.id,
                name: t.name,
                data: t.data,
                isDefault: t.isDefault,
              ),
            )
            .toList();

        if (_templates.isNotEmpty && selectedTemplate == null) {
          selectedTemplate = _templates.firstWhere(
            (t) => t.isDefault,
            orElse: () => _templates.first,
          );
        } else if (selectedTemplate != null) {
          // Keep active selection matching by ID/name
          selectedTemplate = _templates.firstWhere(
            (t) => t.id == selectedTemplate!.id,
            orElse: () => _templates.firstWhere(
              (t) => t.isDefault,
              orElse: () => _templates.first,
            ),
          );
        }
        _isLoadingTemplates = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTemplates = false;
      });
    }
  }

  void _showSaveTemplateDialog(BuildContext context, ImageLayer rootLayer) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return SaveTemplateDialog(
          rootLayer: rootLayer,
          onSaved: _loadTemplates,
        );
      },
    );
  }

  Future<void> _saveExistingTemplate(ImageLayer rootLayer) async {
    final serialized = rootLayer.toJson();
    if (serialized != null &&
        selectedTemplate != null &&
        selectedTemplate!.id != null) {
      final updatedModel = TemplateModel(
        id: selectedTemplate!.id!,
        name: selectedTemplate!.name,
        data: json.encode(serialized),
        isDefault: false,
      );
      await locator<Database>().updateTemplate(updatedModel);
      await _loadTemplates();

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(
              'Template "${selectedTemplate!.name}" updated successfully!',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTemplates || selectedTemplate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    final imageController = ImageController(
      context: context,
      title: widget.title,
      author: widget.poet ?? "",
      poem: widget.poem,
      textStyle: TextStyle(color: colorScheme.onPrimary),
    );

    final layer = selectedTemplate!.getLayers(imageController);

    imageController.padding = layer.getPadding();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () =>
                onSharePressed(context, imageController.poemSeparated.length),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: EditingOption(
                option: "Templates",
                tooltip: "Change Template",
                icon: const Icon(Symbols.stacks),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setModalState) {
                        return _TemplateSelector(
                          selectedTemplate: selectedTemplate!,
                          templates: _templates,
                          onSaveTemplate: () {
                            context.pop();
                            if (selectedTemplate!.isDefault) {
                              _showSaveTemplateDialog(context, layer);
                            } else {
                              _saveExistingTemplate(layer);
                            }
                          },
                          onCreateTemplate: () async {
                            context.pop();
                            final newTemplate = await context.push<Template?>(
                              CustomTemplateCreator.routePath,
                            );
                            if (newTemplate != null) {
                              await _loadTemplates();
                              setState(() {
                                selectedTemplate = newTemplate;
                              });
                            }
                          },
                          onTemplateSelected: (template) async {
                            if (_hasImageBackground(
                              template,
                              imageController,
                            )) {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 50,
                                maxWidth: 800,
                                maxHeight: 800,
                              );
                              if (picked != null) {
                                final bytes = await picked.readAsBytes();
                                final base64Str = base64Encode(bytes);

                                final layer = template.getLayers(
                                  imageController,
                                );
                                final imageLayer = layer
                                    .findLayer<ImageBackgroundLayer>();
                                if (imageLayer != null) {
                                  imageLayer.imageBase64.value = base64Str;
                                }

                                final updatedTemplate = Template(
                                  id: template.id,
                                  name: template.name,
                                  data: json.encode(layer.toJson()),
                                  isDefault: template.isDefault,
                                );

                                setState(() {
                                  selectedTemplate = updatedTemplate;
                                });
                                if (context.mounted) {
                                  context.pop();
                                }
                              }
                            } else {
                              setState(() {
                                selectedTemplate = template;
                              });
                              context.pop();
                            }
                          },
                          onTemplateDeleted: (template) async {
                            if (template.id != null) {
                              await locator<Database>().deleteTemplate(
                                TemplateModel(
                                  id: template.id!,
                                  name: template.name,
                                  data: template.data,
                                  isDefault: template.isDefault,
                                ),
                              );
                              await _loadTemplates();
                              setModalState(() {});
                            }
                          },
                        );
                      },
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSharePressed(BuildContext context, int numberOfPages) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    imageCache.clear();

    final List<String> images = [];

    _showProgressDialog(context);

    for (int pageIndex = 0; pageIndex < numberOfPages; pageIndex++) {
      _pageController.jumpToPage(pageIndex);
      final image = await _getImage(pageIndex);
      images.add(image);
    }

    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }

    // Give the dialog dismissal a frame before
    // opening the platform share sheet.
    await Future<void>.delayed(const Duration(milliseconds: 16));

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
              context.pop();
              await _shareAll(images);
            },
            child: const Text("Share all"),
          ),
          ElevatedButton(
            onPressed: () {
              context.push(ShareImagesScreen.routePath, extra: images);
            },
            child: const Text("Share in parts"),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAll(List<String> images) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            "Made using Heartry 💜\n"
            "Download at https://play.google.com/store/apps/details?id=com.darshan.heartry",
        files: images.map((img) => XFile(img, mimeType: "image/png")).toList(),
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          child: Material(
            child: Center(heightFactor: 3, child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Future<String> _getImage(int index) async {
    final tmpDir = await getTemporaryDirectory();

    final time = DateTime.now().toIso8601String();

    final path = join(tmpDir.path, "${widget.title}-$time-$index.png");

    final imgBytes = await _screenshot.capture(
      pixelRatio: 3,
      delay: const Duration(milliseconds: 100),
    );

    final imgFile = File(path)..writeAsBytes(imgBytes!);

    return imgFile.path;
  }

  bool _hasImageBackground(Template template, ImageController controller) {
    try {
      final layer = template.getLayers(controller);
      return layer.findLayer<ImageBackgroundLayer>() != null;
    } catch (_) {
      return false;
    }
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({
    required this.templates,
    required this.onTemplateSelected,
    required this.selectedTemplate,
    required this.onSaveTemplate,
    required this.onCreateTemplate,
    required this.onTemplateDeleted,
  });

  final Template selectedTemplate;
  final List<Template> templates;
  final VoidCallback onSaveTemplate;
  final VoidCallback onCreateTemplate;
  final ValueChanged<Template> onTemplateSelected;
  final ValueChanged<Template> onTemplateDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scrollController = ScrollController();

    return SizedBox(
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose Template",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => context.pop(),
                        tooltip: "Close",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('create_custom_template_button'),
                          onPressed: onCreateTemplate,
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                          ),
                          label: const Text("Create Custom"),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSaveTemplate,
                          icon: const Icon(Icons.save_rounded, size: 20),
                          label: const Text("Save Current"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isSelected =
                      selectedTemplate.id != null && template.id != null
                      ? selectedTemplate.id == template.id
                      : selectedTemplate.name == template.name;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      tileColor: isSelected
                          ? colorScheme.primary.withAlpha(30)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(color: colorScheme.primary, width: 2)
                            : BorderSide.none,
                      ),
                      leading: template.getIcon(context),
                      title: Text(template.name),
                      trailing: template.isDefault
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete_rounded),
                              onPressed: () {
                                onTemplateDeleted(template);
                              },
                            ),
                      onTap: () {
                        onTemplateSelected(template);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
