import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorGradientListProvider = StateNotifierProviderFamily<
    ColorGradientListProviderNotifier, List<Color>, Color>(
  (_, primaryColor) => ColorGradientListProviderNotifier([
    primaryColor,
    primaryColor.withOpacity(.7),
  ]),
);

class ColorGradientListProviderNotifier extends StateNotifier<List<Color>> {
  ColorGradientListProviderNotifier(super.state);

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
