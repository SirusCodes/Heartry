import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorGradientListProvider =
    StateNotifierProvider<ColorGradientListProviderNotifier>(
  (_) => ColorGradientListProviderNotifier(<Color>[
    Colors.deepPurple.shade600,
    Colors.deepPurple.shade500,
    Colors.deepPurple.shade400,
    Colors.deepPurple.shade300,
    Colors.deepPurple.shade200,
  ]),
);

class ColorGradientListProviderNotifier extends StateNotifier<List<Color>> {
  ColorGradientListProviderNotifier(List<Color> state) : super(state);

  void reorderColors(int oldIndex, int newIndex) {
    final tempList = [...state];

    tempList.insert(newIndex, tempList.removeAt(oldIndex));

    state = tempList;
  }
}
