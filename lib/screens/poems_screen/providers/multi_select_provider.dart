import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/database/database.dart';

final multiSelectEnabledProvider = Provider(
  (ref) => ref.watch(selectedPoemsProvider).isNotEmpty,
  dependencies: [selectedPoemsProvider],
);

final selectedPoemsProvider = NotifierProvider<SelectedPoems, List<PoemModel>>(
  SelectedPoems.new,
);

class SelectedPoems extends Notifier<List<PoemModel>> {
  @override
  List<PoemModel> build() => [];

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
