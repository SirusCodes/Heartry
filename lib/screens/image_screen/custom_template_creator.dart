import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../image_builder/core/image_controller.dart';
import '../../image_builder/core/image_layer.dart';
import '../../image_builder/templates/template.dart';
import '../../image_builder/widgets/page_details.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import 'custom_template_builder.dart';

class CustomTemplateCreator extends StatefulWidget {
  const CustomTemplateCreator({super.key});

  static const String routePath = '/create-template';

  @override
  State<CustomTemplateCreator> createState() => _CustomTemplateCreatorState();
}

class _CustomTemplateCreatorState extends State<CustomTemplateCreator> {
  final _nameController = TextEditingController(text: "My Custom Style");

  LayerType _backgroundType = LayerType.solidBackground;
  String? _imageBase64;
  List<LayerType> _overlayTypes = const [];
  LayerType? _frameType;
  double _outerPaddingH = 40.0;
  double _outerPaddingV = 50.0;
  double _innerPaddingH = 16.0;
  double _innerPaddingV = 16.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  CustomTemplateLayerConfig get _config => CustomTemplateLayerConfig(
    backgroundType: _backgroundType,
    imageBase64: _imageBase64,
    overlayTypes: _overlayTypes,
    frameType: _frameType,
    outerPaddingH: _outerPaddingH,
    outerPaddingV: _outerPaddingV,
    innerPaddingH: _innerPaddingH,
    innerPaddingV: _innerPaddingV,
  );

  Map<String, dynamic> _buildTemplateJson(ImageController controller) {
    return buildCustomTemplateJson(_config, controller);
  }

  Future<void> _saveTemplate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a template name")),
      );
      return;
    }

    final saveController = ImageController(
      context: context,
      title: 'Heartry Preview',
      author: 'Poet Name',
      poem: Delta()
        ..insert("""
This is a live preview of your custom template.

Adjust the configurations below to design it."""),
    );
    final serialized = _buildTemplateJson(saveController);
    final db = locator<Database>();
    final newId = await db.insertTemplate(
      TemplateModel(
        name: name,
        data: json.encode(serialized),
        isDefault: false,
      ),
    );

    if (mounted) {
      Navigator.pop(
        context,
        Template(
          id: newId,
          name: name,
          data: json.encode(serialized),
          isDefault: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final previewController = ImageController(
      context: context,
      title: "Heartry Preview",
      author: "Poet Name",
      poem: Delta()
        ..insert("""
This is a live preview of your custom template.

Adjust the configurations below to design it."""),
      textStyle: TextStyle(color: colorScheme.onPrimary),
    );

    final layer = buildCustomTemplateLayer(_config, previewController);
    previewController.padding = layer.getPadding();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Template"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveTemplate,
            tooltip: "Save Template",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          final previewWidget = Container(
            color: colorScheme.surfaceContainerHighest.withAlpha(50),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 360,
                      height: 640,
                      child: LayoutBuilder(
                        builder: (context, previewConstraints) {
                          previewController.constraints = previewConstraints;
                          return ListenableBuilder(
                            listenable: previewController,
                            builder: (context, child) => PageDetails(
                              currentPage: 0,
                              // ignore: invalid_use_of_protected_member
                              child: layer.build(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          final configWidget = SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Template Identity",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('template_name_field'),
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Template Name",
                    prefixIcon: const Icon(Symbols.label_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Background Style",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildBackgroundChip(
                      "Solid",
                      LayerType.solidBackground,
                      Icons.circle_rounded,
                    ),
                    _buildBackgroundChip(
                      "Gradient",
                      LayerType.gradientBackground,
                      Icons.gradient_rounded,
                    ),
                    _buildBackgroundChip(
                      "Image",
                      LayerType.imageBackground,
                      Symbols.image_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Overlay Style",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildOverlayChip(
                      "None",
                      const [],
                      Icons.do_not_disturb_on_rounded,
                    ),

                    _buildOverlayChip("Bubble", const [
                      LayerType.bubbleOverlay,
                    ], Icons.bubble_chart_rounded),

                    _buildOverlayChip("Blur", const [
                      LayerType.blurOverlay,
                    ], Icons.blur_on_rounded),

                    _buildOverlayChip("Translucent", const [
                      LayerType.translucentOverlay,
                    ], Icons.opacity_rounded),

                    _buildOverlayChip("Blur + Translucent", const [
                      LayerType.translucentOverlay,
                      LayerType.blurOverlay,
                    ], Icons.blur_linear_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Frame Style",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildFrameChip(
                      "None",
                      null,
                      Icons.do_not_disturb_on_rounded,
                    ),
                    _buildFrameChip(
                      "Frosted Glass",
                      LayerType.frostedGlass,
                      Symbols.blur_circular_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Outer Padding",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPaddingSlider(
                  title: "Horizontal Outer Padding",
                  value: _outerPaddingH,
                  max: 100,
                  onChanged: (val) => setState(() => _outerPaddingH = val),
                ),
                _buildPaddingSlider(
                  title: "Vertical Outer Padding",
                  value: _outerPaddingV,
                  max: 100,
                  onChanged: (val) => setState(() => _outerPaddingV = val),
                ),
                if (_frameType == LayerType.frostedGlass) ...[
                  const SizedBox(height: 24),
                  Text(
                    "Inner Padding",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaddingSlider(
                    title: "Horizontal Inner Padding",
                    value: _innerPaddingH,
                    max: 50,
                    onChanged: (val) => setState(() => _innerPaddingH = val),
                  ),
                  _buildPaddingSlider(
                    title: "Vertical Inner Padding",
                    value: _innerPaddingV,
                    max: 50,
                    onChanged: (val) => setState(() => _innerPaddingV = val),
                  ),
                ],
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: previewWidget),
                Expanded(flex: 5, child: configWidget),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(flex: 3, child: previewWidget),
                Expanded(flex: 4, child: configWidget),
              ],
            );
          }
        },
      ),
    );
  }

  bool _areListsEqual(List<LayerType> a, List<LayerType> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildBackgroundChip(String label, LayerType value, IconData icon) {
    final isSelected = _backgroundType == value;
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          if (value == LayerType.imageBackground) {
            final picker = ImagePicker();
            final picked = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 50,
              maxWidth: 800,
              maxHeight: 800,
            );
            if (picked != null) {
              final bytes = await picked.readAsBytes();
              setState(() {
                _imageBase64 = base64Encode(bytes);
                _backgroundType = LayerType.imageBackground;
              });
            } else {
              // Revert/do not switch background selection, keeping the previous active selection.
            }
          } else {
            setState(() {
              _backgroundType = value;
            });
          }
        }
      },
    );
  }

  Widget _buildOverlayChip(String label, List<LayerType> value, IconData icon) {
    final isSelected = _areListsEqual(_overlayTypes, value);
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _overlayTypes = value;
          });
        }
      },
    );
  }

  Widget _buildFrameChip(String label, LayerType? value, IconData icon) {
    final isSelected = _frameType == value;
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _frameType = value;
          });
        }
      },
    );
  }

  Widget _buildPaddingSlider({
    required String title,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13)),
            Text(
              "${value.toStringAsFixed(0)} px",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: max.toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
