import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_info_widget.dart';

class SupportDevelopment extends StatelessWidget {
  const SupportDevelopment({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInfoWidget(
      title: "SUPPORT DEVELOPMENT",
      children: [
        ListTile(
          title: const Text("GitHub"),
          subtitle: const Text("Fork the project on GitHub"),
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/logos/GitHub-Mark.png"),
          ),
          onTap: () => _launchURL("https://github.com/SirusCodes/Heartry"),
        ),
        ListTile(
          title: const Text("Rate the app"),
          subtitle: const Text(
            "Love this app? Let us know in Google Play Store",
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.star),
          ),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Donate"),
          subtitle: const Text(
            "If you think that we deserve some money for our work," +
                " you can leave some amount here.",
          ),
          leading: const CircleAvatar(child: Icon(Icons.card_giftcard_rounded)),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Share"),
          subtitle: const Text("Share it with your friends and family"),
          leading: const CircleAvatar(child: Icon(Icons.share)),
          onTap: () {},
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
