import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/image_screen/image_screen.dart';

class ShareHelper {
  static void shareAsText({
    required String? title,
    required String poem,
    required String poet,
  }) {
    String msg = "";

    if (title != null && title.isNotEmpty) msg += "$title\n\n";

    msg += poem;
    msg += "\n\n-$poet";

    Share.share(msg);
  }

  static void shareAsImage(
    BuildContext context, {
    required String? title,
    required String poem,
    required String poet,
  }) {
    Navigator.push<void>(
      context,
      CupertinoPageRoute(
        builder: (_) => ImageScreen(
          title: title,
          poem: poem.split("\n"),
          poet: poet,
        ),
      ),
    );
  }
}
