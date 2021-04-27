import 'package:flutter/cupertino.dart';
import 'package:heartry/database/config.dart';
import 'package:heartry/screens/image_screen/image_screen.dart';
import 'package:share/share.dart';

import '../init_get_it.dart';

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
