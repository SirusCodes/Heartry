import 'package:flutter/material.dart';
import '../screens/image_screen/image_screen.dart';
import 'package:share_plus/share_plus.dart';

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

    SharePlus.instance.share(ShareParams(text: msg));
  }

  static void shareAsImage(
    BuildContext context, {
    required String? title,
    required String poem,
    required String poet,
  }) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ImageScreen(title: title, poem: poem, poet: poet),
      ),
    );
  }
}
