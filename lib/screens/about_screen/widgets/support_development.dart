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
