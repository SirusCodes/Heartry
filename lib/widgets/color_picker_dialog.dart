import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

typedef OkResponseColorPicker =
    void Function(Color selectedColor, bool dynamicColorStatus);

void showColorPickerWithDynamic({
  required BuildContext context,
  required Color? currentColor,
  required OkResponseColorPicker onOkPressed,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: _ColorPickerWithDynamic(
        currentColor: currentColor,
        onOkPressed: onOkPressed,
      ),
    ),
  );
}

class _ColorPickerWithDynamic extends StatefulWidget {
  const _ColorPickerWithDynamic({
    required this.currentColor,
    required this.onOkPressed,
  });

  final Color? currentColor;
  final OkResponseColorPicker onOkPressed;

  @override
  State<_ColorPickerWithDynamic> createState() =>
      _ColorPickerWithDynamicState();
}

class _ColorPickerWithDynamicState extends State<_ColorPickerWithDynamic> {
  late Color? selectedColor;
  late bool isDynamic;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.currentColor;
    isDynamic = widget.currentColor == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Switch(
                value: isDynamic,
                onChanged: (_) => setState(() => isDynamic = !isDynamic),
              ),
              const SizedBox(width: 8),
              const Text("Use Dynamic theme"),
            ],
          ),
        ),
        if (!isDynamic)
          ColorPicker(
            color: selectedColor ?? Colors.white,
            onColorChanged: (color) => setState(() => selectedColor = color),
            width: 40,
            height: 40,
            borderRadius: 4,
            spacing: 5,
            runSpacing: 5,
            enableShadesSelection: false,
            heading: const Text('Select color'),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.primary: false,
            },
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isDynamic || selectedColor != null
                    ? () {
                        if (selectedColor != null)
                          widget.onOkPressed(selectedColor!, isDynamic);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text("Ok"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showColorPicker({
  required BuildContext context,
  required Color? currentColor,
  required ValueChanged<Color> onOkPressed,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ColorPaletteSelector(
        currentColor: currentColor,
        onColorSelected: onOkPressed,
      ),
    ),
  );
}

class ColorPaletteSelector extends StatefulWidget {
  const ColorPaletteSelector({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  final Color? currentColor;
  final ValueChanged<Color> onColorSelected;

  @override
  State<ColorPaletteSelector> createState() => _ColorPaletteSelectorState();
}

class _ColorPaletteSelectorState extends State<ColorPaletteSelector> {
  late Color? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorPicker(
          color: selectedColor ?? Colors.blue,
          onColorChanged: (color) => setState(() => selectedColor = color),
          width: 35,
          height: 35,
          borderRadius: 4,
          spacing: 5,
          runSpacing: 5,
          enableTonalPalette: true,
          subheading: const Text('Select color shade'),
          tonalSubheading: const Text('Select tonal shade'),
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.wheel: true,
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (selectedColor != null)
                    widget.onColorSelected(selectedColor!);
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
