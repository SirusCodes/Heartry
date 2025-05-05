import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/color_gradient_provider.dart';
import '../../../../utils/color_helper.dart';
import '../../../../widgets/color_picker_dialog.dart';

class GradientBackgroundColor extends StatelessWidget {
  const GradientBackgroundColor({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.color_lens_rounded),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return const _GradientBackgroundColorHandler();
          },
        );
      },
    );
  }
}

class _GradientBackgroundColorHandler extends ConsumerWidget {
  const _GradientBackgroundColorHandler();

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
                  currentColor: null,
                  onOkPressed: (color) => ref
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
                onOkPressed: (color) => ref
                    .read(colorGradientListProvider(primaryColor).notifier)
                    .changeColor(color, i),
              ),
            ),
        ],
      ),
    );
  }
}
