import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../database/config.dart';
import '../init_get_it.dart';
import '../screens/image_screen/image_screen.dart';

class ShareHelper {
  static void shareAsText({required String? title, required String poem}) {
    String msg = "";

    if (title != null && title.isNotEmpty) msg += "$title\n\n";

    msg += poem;
    msg += "\n\n-${locator<Config>().name}";

    Share.share(msg);
  }

  static void shareAsImage(
    BuildContext context, {
    required String? title,
    required String poem,
  }) {
    Navigator.push<void>(
      context,
      CupertinoPageRoute(
        builder: (_) => ImageScreen(
          title: title,
          poem: poem.split("\n"),
          poet: locator<Config>().name,
        ),
      ),
    );
  }
}
