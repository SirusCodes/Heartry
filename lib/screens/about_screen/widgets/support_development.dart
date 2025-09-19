import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/image_color_invert.dart';
import 'base_info_widget.dart';

class SupportDevelopment extends StatelessWidget {
  const SupportDevelopment({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseInfoWidget(
      title: "SUPPORT DEVELOPMENT",
      children: [
        ListTile(
          title: const Text("GitHub"),
          subtitle: const Text("Contribute to the project."),
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: ImageColorInvert(
              image: Image.asset("assets/logos/GitHub-Mark.png"),
              invert: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
          onTap: () => _launchURL("https://github.com/SirusCodes/Heartry"),
        ),
        ListTile(
          title: const Text("Rate the app"),
          subtitle: const Text(
            "Love this app? Let us know in the Play Store!",
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.star),
          ),
          onTap: () => _launchURL(
            "https://play.google.com/store/apps/details?id=com.darshan.heartry",
          ),
        ),
        ListTile(
          title: const Text("Join Telegram Group"),
          subtitle: const Text("Help us by saying what's important to you."),
          leading: const CircleAvatar(child: Icon(Icons.groups_2_rounded)),
          onTap: () => launchUrlString(
            "https://t.me/heartry",
            mode: LaunchMode.externalApplication,
          ),
        ),
        // ListTile(
        //   title: const Text("Donate"),
        //   subtitle: const Text(
        //     "If you think that we deserve some money for our work," +
        //         " you can leave some amount here.",
        //   ),
        // ignore: lines_longer_than_80_chars
        // leading: const CircleAvatar(child: Icon(Icons.card_giftcard_rounded)),
        //   onTap: () {},
        // ),
        ListTile(
          title: const Text("Send us Feature request"),
          subtitle: const Text(
            "Tell us what new features you want in future updates.",
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.flare_outlined),
          ),
          onTap: () => _launchURL(
            "mailto:heartryapp@gmail.com?&subject=Feature request",
          ),
        ),
        ListTile(
          title: const Text("Report a bug"),
          subtitle: const Text(
            "App is not working as expected? Send us a bug report.",
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.bug_report_rounded),
          ),
          onTap: () => _launchURL(
            "mailto:heartryapp@gmail.com?&subject=Bug report",
          ),
        ),
        ListTile(
          title: const Text("Share"),
          subtitle: const Text("Share it with your friends and family."),
          leading: const CircleAvatar(child: Icon(Icons.share)),
          onTap: () => SharePlus.instance.share(ShareParams(
            text:
                "Hey, kindly checkout Heartry - An app for Writers on playstore at https://play.google.com/store/apps/details?id=com.darshan.heartry",
          )),
        ),
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
