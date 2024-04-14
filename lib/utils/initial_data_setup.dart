import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/config.dart';
import '../database/database.dart';
import '../init_get_it.dart';

class InitialDataSetup {
  static Future<void> addDefaultData(String name, WidgetRef ref) async {
    ref.read(configProvider.notifier).name = name;
    await addDetailsInDB(name);
  }

  static Future<void> addDetailsInDB(String name) async {
    final db = locator<Database>();

    StringBuffer buffer = StringBuffer();

    buffer.writeln("Hey $name, thanks for using Heartry. 🤗");
    buffer.writeln();
    buffer.writeln("Everything that you ✍ will be auto saved.");
    buffer.writeln();
    buffer.writeln("""Press and hold this card to access toolbar. 😊
You can access Reader Mode, Share and Edit from it.""");
    buffer.writeln();
    buffer.writeln("""**Reader Mode**
Sometimes keyboards can be annoying.
Press and hold on card, and click on eye button.
Now that keyboard will never disturb you. 😇""");
    buffer.writeln();
    buffer.writeln("""**Share**
You can share poem in 2 ways.
1. As Text 🆎 (For Messages)
2. As Photos 📷 (For Stories)""");

    await db.insertPoem(PoemModel(
      title: "Welcome!!🎉",
      poem: buffer.toString(),
    ));
  }
}
