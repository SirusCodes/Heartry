import 'package:flutter/material.dart';

import '../utils/color_helper.dart';
import 'color_picker_dialog.dart';

class GradientPaletteSelector extends StatelessWidget {
  const GradientPaletteSelector({
    super.key,
    required this.gradient,
    required this.onChanged,
  });

  final List<Color> gradient;
  final ValueChanged<List<Color>> onChanged;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 300,
      child: ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                "Customize Gradient",
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => showColorPicker(
                  context: context,
                  currentColor: primaryColor,
                  onOkPressed: (color) {
                    onChanged([...gradient, color]);
                  },
                ),
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex != newIndex) {
            final newList = List<Color>.from(gradient);
            newList.insert(newIndex, newList.removeAt(oldIndex));
            onChanged(newList);
          }
        },
        children: [
          for (var i = 0; i < gradient.length; i++)
            ListTile(
              key: ValueKey("${gradient[i].hashCode}-$i"),
              tileColor: gradient[i],
              leading: Icon(
                Icons.menu,
                color: useWhiteForeground(gradient[i])
                    ? Colors.white
                    : Colors.black,
              ),
              trailing: gradient.length > 2
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: useWhiteForeground(gradient[i])
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        final newList = List<Color>.from(gradient);
                        newList.removeAt(i);
                        onChanged(newList);
                      },
                    )
                  : null,
              onTap: () => showColorPicker(
                context: context,
                currentColor: gradient[i],
                onOkPressed: (color) => onChanged(
                  List.from(gradient.map((e) => e == gradient[i] ? color : e)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
