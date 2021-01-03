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

  TextEditingController textEditingController;

  ListQueue<String> undoStack, redoStack;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

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

    String result;

    do {
      result = undoStack.removeFirst();
      if (redoStack.isEmpty || result != redoStack.first)
        redoStack.addFirst(result);
    } while (result == textEditingController.text);

    notifyListeners();
    textEditingController.text = result;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: result.length),
    );
  }

  void redo() {
    if (!canRedo) return;

    String result;
    do {
      result = redoStack.removeFirst();
      if (undoStack.isEmpty || result != undoStack.first)
        undoStack.addFirst(result);
    } while (result == textEditingController.text);

    notifyListeners();
    textEditingController.text = result;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: result.length),
    );
  }
}
