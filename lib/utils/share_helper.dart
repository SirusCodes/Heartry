import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
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

    SharePlus.instance.share(ShareParams(text: msg));
  }

  static void shareAsImage(
    BuildContext context, {
    required String? title,
    required Delta poem,
    required String poet,
  }) {
    context.push(
      ImageScreen.routePath,
      extra: {'title': title, 'poem': poem, 'poet': poet},
    );
  }
}
