import 'package:get_it/get_it.dart';

import 'utils/undo_redo.dart';

final locator = GetIt.instance;

void initGetIt() {
  locator.registerLazySingleton(() => UndoRedo());
}
