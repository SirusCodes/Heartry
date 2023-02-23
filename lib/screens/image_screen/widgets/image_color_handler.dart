import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/color_gradient_provider.dart';
import '../../../widgets/color_picker_dialog.dart';

class ImageColorHandler extends ConsumerWidget {
  const ImageColorHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final gradientList = ref.watch(colorGradientListProvider(primaryColor));

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
                  currentColor: Colors.white,
                  onColorChanged: (color) => ref
                      .read(colorGradientListProvider(primaryColor).notifier)
                      .addColor(color),
                ),
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex != newIndex)
            ref
                .read(colorGradientListProvider(primaryColor).notifier)
                .reorderColors(
                  oldIndex,
                  oldIndex > newIndex ? newIndex : newIndex - 1,
                );
        },
        children: [
          for (var i = 0; i < gradientList.length; i++)
            ListTile(
              key: ValueKey("${gradientList[i].hashCode}-$i"),
              tileColor: gradientList[i],
              leading: Icon(
                Icons.menu,
                color: useWhiteForeground(gradientList[i])
                    ? Colors.white
                    : Colors.black,
              ),
              trailing: gradientList.length > 2
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: useWhiteForeground(gradientList[i])
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () => ref
                          .read(
                              colorGradientListProvider(primaryColor).notifier)
                          .removeColor(i),
                    )
                  : null,
              onTap: () => showColorPicker(
                context: context,
                currentColor: gradientList[i],
                onColorChanged: (color) => ref
                    .read(colorGradientListProvider(primaryColor).notifier)
                    .changeColor(color, i),
              ),
            ),
        ],
      ),
    );
  }

  // FROM https://github.com/mchome/flutter_colorpicker/blob/9b4942b6e6fa79fb78661f95531106afd1ed5d9f/lib/src/utils.dart#L15
  bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
    int v = math
        .sqrt(math.pow(backgroundColor.red, 2) * 0.299 +
            math.pow(backgroundColor.green, 2) * 0.587 +
            math.pow(backgroundColor.blue, 2) * 0.114)
        .round();
    return v < 130 + bias ? true : false;
  }
}
