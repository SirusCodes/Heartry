import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/database/database.dart';

final multiSelectEnabledProvider = Provider(
  (ref) => ref.watch(selectedPoemsProvider).isNotEmpty,
);

final selectedPoemsProvider = StateNotifierProvider((_) => SelectedPoems());

class SelectedPoems extends StateNotifier<List<PoemModel>> {
  SelectedPoems() : super([]);

  void toggle(PoemModel poem) {
    final index = state.indexWhere((t) => t.id == poem.id);

    if (index == -1) {
      state = [...state, poem];
    } else {
      state = [...state..removeAt(index)];
    }
  }

  void add(PoemModel poem) {
    state = [...state, poem];
  }

  void remove(PoemModel poem) {
    final updated = state..removeWhere((t) => t.id == poem.id);
    state = [...updated];
  }

  void clear() {
    state = [];
  }
}
