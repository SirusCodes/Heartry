import 'package:get_it/get_it.dart';

import 'database/database.dart';

final locator = GetIt.instance;

void initGetIt() {
  locator.registerSingleton<Database>(Database());
}
