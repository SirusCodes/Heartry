import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/color_gradient_provider.dart';

class ImageColorHandler extends ConsumerWidget {
  const ImageColorHandler({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _gradientList = watch(colorGradientListProvider.state);
    return SizedBox(
      height: 300,
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex != newIndex)
            context.read(colorGradientListProvider).reorderColors(
                  oldIndex,
                  oldIndex > newIndex ? newIndex : newIndex - 1,
                );
        },
        children: [
          ..._gradientList
              .map((e) => ListTile(
                    key: ValueKey(e.value),
                    tileColor: e,
                  ))
              .toList()
        ],
      ),
    );
  }
}
