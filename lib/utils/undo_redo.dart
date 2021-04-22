import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../init_get_it.dart';

final undoRedoProvider = ChangeNotifierProvider<UndoRedo>(
  (_) => locator<UndoRedo>(),
);

class UndoRedo extends ChangeNotifier {
  UndoRedo() {
    undoStack = ListQueue<String>();
    redoStack = ListQueue<String>();
  }

  late TextEditingController textEditingController;

  late ListQueue<String> undoStack, redoStack;

  bool get canUndo {
    return undoStack.isNotEmpty && undoStack.last != textEditingController.text;
  }

  bool get canRedo {
    return redoStack.isNotEmpty && redoStack.last != textEditingController.text;
  }

  void clearAllStack() {
    undoStack.clear();
    redoStack.clear();
  }

  void registerChange(String change) {
    undoStack.addFirst(change);
    redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;

    final result = undoStack.removeFirst();
    redoStack.addFirst(result);

    printStacks();

    notifyListeners();
    textEditingController.text = undoStack.first;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: undoStack.first.length),
    );
  }

  void redo() {
    if (!canRedo) return;

    final result = redoStack.removeFirst();
    undoStack.addFirst(result);

    printStacks();

    notifyListeners();
    textEditingController.text = result;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: result.length),
    );
  }

  void printStacks() {
    debugPrint("Undo $undoStack");
    debugPrint("Redo $redoStack");
  }
}
