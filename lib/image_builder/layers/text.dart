import 'package:flutter/material.dart';
import 'package:heartry/image_builder/widgets/editing_option.dart';
import '../core/font_family.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../widgets/color_picker_dialog.dart';
import '../widgets/page_details.dart';
import '../widgets/poem_image_text.dart';
import '../core/image_controller.dart';
import '../core/image_layer.dart';

class TextLayer extends ImageLayer {
  TextLayer({
    super.key,
    required this.controller,
  }) : super(nextLayer: null);

  final _textScale = ValueNotifier<double>(1.0);
  final _textColor = ValueNotifier<Color?>(null);
  final _fontFamily = ValueNotifier<FontFamily>(FontFamily.caveat);

  final ImageController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentPage = PageDetails.of(context).currentPage;

    return ListenableBuilder(
      listenable: Listenable.merge([_textScale, _textColor, _fontFamily]),
      builder: (context, child) {
        return PoemImageText(
          poem: controller.poemSeparated[currentPage],
          title: controller.title,
          poet: controller.author,
          color: _textColor.value ?? colorScheme.onPrimary,
          scale: _textScale.value,
          fontFamily: _fontFamily.value,
        );
      },
    );
  }

  @override
  List<Widget> getEditingOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      EditingOption(
        option: "Text Color",
        icon: Icon(Icons.format_color_text_rounded),
        tooltip: "Text Color",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: _textColor,
                  builder: (context, colorValue, child) => ColorPaletteSelector(
                    currentColor: colorValue ?? colorScheme.onPrimary,
                    onColorSelected: (color) {
                      _textColor.value = color;
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      EditingOption(
        option: "Text Size",
        icon: Icon(Icons.format_size_rounded),
        tooltip: "Text Size",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return ValueListenableBuilder(
                valueListenable: _textScale,
                builder: (context, value, child) => _TextSizeHandler(
                  value: value,
                  onChanged: (value) {
                    controller.textSizeFactor = value;
                    _textScale.value = value;
                  },
                ),
              );
            },
          );
        },
      ),
      EditingOption(
        option: "Font Family",
        icon: Icon(Symbols.font_download_rounded),
        tooltip: "Font Family",
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return ValueListenableBuilder(
                valueListenable: _fontFamily,
                builder: (context, value, child) => _FontFamilyHandler(
                  value: value,
                  onChanged: (value) {
                    controller.textStyle = controller.textStyle.copyWith(
                      fontFamily: value.name,
                    );
                    _fontFamily.value = value;
                  },
                ),
              );
            },
          );
        },
      ),
      ...super.getEditingOptions(context)
    ];
  }

  @override
  void dispose() {
    _textScale.dispose();
    _textColor.dispose();
    _fontFamily.dispose();
    super.dispose();
  }
}

class _TextSizeHandler extends StatelessWidget {
  const _TextSizeHandler({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "${value.toStringAsPrecision(2)}x",
              style: TextStyle(fontSize: 20),
            ),
            Slider(
              value: value,
              min: 0.8,
              max: 2,
              divisions: 12,
              label: value.toStringAsPrecision(2),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _FontFamilyHandler extends StatelessWidget {
  const _FontFamilyHandler({
    required this.value,
    required this.onChanged,
  });

  final FontFamily value;
  final ValueChanged<FontFamily> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const fonts = FontFamily.values;

    return ListView.builder(
      itemCount: fonts.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final font = fonts[index];
        final isSelected = value == font;

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
            title: Text(
              font.displayName,
              style: TextStyle(fontFamily: font.name, fontSize: 25),
            ),
            onTap: () {
              onChanged(font);
            },
          ),
        );
      },
    );
  }
}
