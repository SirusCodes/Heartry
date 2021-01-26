import 'package:get_it/get_it.dart';

import 'database/config.dart';
import 'database/database.dart';
import 'utils/undo_redo.dart';

final locator = GetIt.instance;

void initGetIt() {
  locator.registerLazySingleton(() => UndoRedo());
  locator.registerSingleton<Database>(Database());
  locator.registerSingleton<Config>(Config());
}
