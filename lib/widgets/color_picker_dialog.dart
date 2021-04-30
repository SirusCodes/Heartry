import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({
    Key? key,
    required this.currentColor,
    required this.selectedColor,
  }) : super(key: key);

  final Color currentColor;
  final Function(Color) selectedColor;

  @override
  Widget build(BuildContext context) {
    Color selected = Colors.white;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            selected = color;
          },
          pickerAreaHeightPercent: 0.7,
          displayThumbColor: true,
          pickerAreaBorderRadius: const BorderRadius.vertical(
            top: Radius.circular(2.0),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            selectedColor(selected);
            Navigator.pop(context);
          },
          child: const Text("Select"),
        )
      ],
    );
  }
}
