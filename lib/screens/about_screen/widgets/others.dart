import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_info_widget.dart';

class Others extends StatelessWidget {
  const Others({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseInfoWidget(
          title: "OTHERS",
          children: [
            ListTile(
              title: const Text("Change log"),
              subtitle: const Text("Changes made to the project"),
              leading: const CircleAvatar(child: Icon(Icons.sticky_note_2)),
              onTap: () => _launchURL(
                "https://github.com/SirusCodes/Heartry/blob/main/CHANGELOG.md",
              ),
            ),
            ListTile(
              title: const Text("Version"),
              subtitle: const Text("1.0.0"),
              leading: const CircleAvatar(child: Icon(Icons.info)),
              onTap: () {},
            ),
          ],
        ),
        Text(
          "Made with ❤ in India",
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
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
