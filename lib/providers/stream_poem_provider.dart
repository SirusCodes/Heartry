import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../init_get_it.dart';

final streamPoemProvider = StreamProvider<List<PoemModel>>((ref) {
  return locator<Database>().getPoemStream;
});
