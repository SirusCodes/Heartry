/*import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../init_get_it.dart';
import '../models/selected_poem_model.dart';

final poemProvider = StateNotifierProvider.autoDispose<PoemProvider>(
  (_) => PoemProvider(),
);

class PoemProvider extends StateNotifier<AsyncValue<List<SelectedPoemModel>>> {
  PoemProvider() : super(const AsyncLoading()) {
    _getPoems();
  }

  StreamSubscription<List<SelectedPoemModel>> poemStream;

  @override
  void dispose() {
    poemStream.cancel();
    super.dispose();
  }

  void _getPoems() {
    poemStream = locator<Database>().getPoemStream.listen(
      (poemModels) {
        state = AsyncData(poemModels);
      },
      onError: (Object err, StackTrace st) {
        state = AsyncError(err, st);
      },
    );
  }

  void onLongPress(int index) {
    final temp = state.data?.value;
    temp[index].isSelected = !temp[index].isSelected;
    state = AsyncData(temp);
  }

  bool get showDelete {
    return state.when(
      data: (poems) {
        for (final poem in poems) if (poem.isSelected) return true;
        return false;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }
}
*/
