import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/open_source_libraries.dart';
import 'base_info_widget.dart';

class Others extends StatelessWidget {
  const Others({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInfoWidget(
      title: "SUPPORT DEVELOPMENT",
      children: [
        ListTile(
          title: const Text("Change log"),
          subtitle: const Text("What changes were made in the versions"),
          leading: const CircleAvatar(child: Icon(Icons.sticky_note_2)),
          onTap: () => _launchURL(
            "https://github.com/SirusCodes/Heartry/blob/main/CHANGELOG.md",
          ),
        ),
        ListTile(
          title: const Text("Open source licences"),
          subtitle: const Text("What libraries were used for the development"),
          leading: const CircleAvatar(child: Icon(Icons.book)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OpenSourceLibraries(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text("Version"),
          subtitle: const Text("1.0.0"),
          leading: const CircleAvatar(child: Icon(Icons.info)),
          onTap: () {},
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
