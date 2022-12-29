import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

void showColorPicker({
  required BuildContext context,
  required Color currentColor,
  required ValueChanged<Color> onColorChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: _ColorPicker(
        currentColor: currentColor,
        onColorChanged: onColorChanged,
      ),
    ),
  );
}

class _ColorPicker extends StatefulWidget {
  const _ColorPicker({
    Key? key,
    required this.currentColor,
    required this.onColorChanged,
  }) : super(key: key);

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late Color selectedColor;

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
          color: selectedColor,
          onColorChanged: (color) => setState(() => selectedColor = color),
          width: 40,
          height: 40,
          borderRadius: 4,
          spacing: 5,
          runSpacing: 5,
          heading: const Text('Select color'),
          subheading: const Text('Select color shade'),
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
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
                  widget.onColorChanged(selectedColor);
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          ),
        )
      ],
    );
  }
}
