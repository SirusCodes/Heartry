import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorGradientListProvider =
    StateNotifierProvider<ColorGradientListProviderNotifier, List<Color>>(
  (_) => ColorGradientListProviderNotifier(<Color>[
    Colors.deepPurple.shade600,
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

  void addColor(Color color) {
    final tempList = [...state];
    tempList.add(color);
    state = tempList;
  }

  void changeColor(Color color, int index) {
    final tempList = [...state];
    tempList[index] = color;
    state = tempList;
  }

  void removeColor(int index) {
    if (state.length > 2) {
      final tempList = [...state];
      tempList.removeAt(index);
      state = tempList;
    }
  }
}
