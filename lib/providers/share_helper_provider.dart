import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share/share.dart';

import '../screens/image_screen/image_screen.dart';
import 'shared_prefs_provider.dart';

final shareHelperProvider = Provider<ShareHelperProvider>((ref) {
  return ShareHelperProvider(ref.read(sharedPrefsProvider));
});

class ShareHelperProvider {
  ShareHelperProvider(this._sharedPrefs);

  final SharedPrefsProvider _sharedPrefs;

  void shareAsText({required String? title, required String poem}) {
    String msg = "";

    if (title != null && title.isNotEmpty) msg += "$title\n\n";

    msg += poem;
    msg += "\n\n-${_sharedPrefs.name}";

    Share.share(msg);
  }

  void shareAsImage(
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
          poet: _sharedPrefs.name,
        ),
      ),
    );
  }
}
