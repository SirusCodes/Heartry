import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'base_info_widget.dart';

class Others extends StatelessWidget {
  const Others({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseInfoWidget(
          title: "OTHERS",
          children: [
            ListTile(
              title: const Text("Change log"),
              subtitle: const Text("Changes made to the project."),
              leading: const CircleAvatar(child: Icon(Icons.sticky_note_2)),
              onTap: () => _launchURL(
                "https://github.com/SirusCodes/Heartry/blob/main/CHANGELOG.md",
              ),
            ),
            ListTile(
              title: const Text("Privacy statement"),
              subtitle: const Text("Our commitment towards privacy."),
              leading: const CircleAvatar(child: Icon(Icons.book)),
              onTap: () {
                _launchURL("https://heartry.darshanrander.com/policy");
              },
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) => ListTile(
                title: const Text("Version"),
                subtitle: snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? Text(snapshot.data!.version)
                    : const Text("Can't get version"),
                leading: const CircleAvatar(child: Icon(Icons.info)),
                onTap: () {},
              ),
            ),
          ],
        ),
        Text(
          "Made with ❤ in India",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
