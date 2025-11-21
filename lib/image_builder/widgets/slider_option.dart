import 'package:flutter/material.dart';

class SliderOption extends StatelessWidget {
  const SliderOption({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Text(title, style: const TextStyle(fontSize: 18)),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
