import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../database/config.dart';
import '../init_get_it.dart';
import '../screens/image_screen/image_screen.dart';

class ShareOptionList extends StatelessWidget {
  const ShareOptionList({
    Key? key,
    this.onShare,
    required this.title,
    required this.poem,
  }) : super(key: key);

  final VoidCallback? onShare;
  final String? title;
  final String poem;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: const Text("Share as Text"),
          trailing: const Icon(Icons.text_fields),
          onTap: () {
            onShare?.call();
            String msg = "";

            if (title != null && title!.isNotEmpty) msg += "$title\n\n";

            msg += poem;
            msg += "\n\n-${locator<Config>().name}";

            Share.share(msg);
          },
        ),
        ListTile(
          title: const Text("Share as Image"),
          trailing: const Icon(Icons.image),
          onTap: () {
            onShare?.call();
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
          },
        ),
      ],
    );
  }
}
