import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/color_gradient_provider.dart';
import '../../../widgets/color_picker_dialog.dart';

class ImageColorHandler extends ConsumerWidget {
  const ImageColorHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _gradientList = watch(colorGradientListProvider);
    return SizedBox(
      height: 300,
      child: ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                "Customize Gradient",
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  _showColorPicker(context, Colors.white);
                },
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex != newIndex)
            context.read(colorGradientListProvider.notifier).reorderColors(
                  oldIndex,
                  oldIndex > newIndex ? newIndex : newIndex - 1,
                );
        },
        children: [
          for (var i = 0; i < _gradientList.length; i++)
            ListTile(
              key: ValueKey("${_gradientList[i].hashCode}-$i"),
              tileColor: _gradientList[i],
              leading: Icon(
                Icons.menu,
                color: useWhiteForeground(_gradientList[i])
                    ? Colors.white
                    : Colors.black,
              ),
              trailing: _gradientList.length > 2
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: useWhiteForeground(_gradientList[i])
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        context
                            .read(colorGradientListProvider.notifier)
                            .removeColor(i);
                      },
                    )
                  : null,
              onTap: () {
                _showColorPicker(context, _gradientList[i], i);
              },
            ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor,
      [int? index]) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          currentColor: currentColor,
          selectedColor: (color) {
            index == null
                ? context
                    .read(colorGradientListProvider.notifier)
                    .addColor(color)
                : context
                    .read(colorGradientListProvider.notifier)
                    .changeColor(color, index);
          },
        );
      },
    );
  }
}
