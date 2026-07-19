import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/image_color_invert.dart';
import '../../../utils/url_launcher_helper.dart';
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
          onTap: () => context.safeLaunchURL(
            "https://github.com/SirusCodes/Heartry",
            name: "GitHub",
          ),
        ),
        ListTile(
          title: const Text("Rate the app"),
          subtitle: const Text("Love this app? Let us know in the Play Store!"),
          leading: const CircleAvatar(child: Icon(Icons.star)),
          onTap: () => context.safeLaunchURL(
            "https://play.google.com/store/apps/details?id=com.darshan.heartry",
            name: "Play Store",
          ),
        ),
        ListTile(
          title: const Text("Join Reddit Community"),
          subtitle: const Text("Help us by saying what's important to you."),
          leading: const CircleAvatar(child: Icon(Icons.groups_2_rounded)),
          onTap: () => context.safeLaunchURL(
            "https://www.reddit.com/r/Heartry/",
            name: "Reddit Community",
            mode: LaunchMode.externalApplication,
          ),
        ),
        ListTile(
          title: const Text("Send us Feature request"),
          subtitle: const Text(
            "Tell us what new features you want in future updates.",
          ),
          leading: const CircleAvatar(child: Icon(Icons.flare_outlined)),
          onTap: () => context.safeLaunchURL(
            "mailto:heartryapp@gmail.com?&subject=Feature request",
            name: "Feature request email",
          ),
        ),
        ListTile(
          title: const Text("Report a bug"),
          subtitle: const Text(
            "App is not working as expected? Send us a bug report.",
          ),
          leading: const CircleAvatar(child: Icon(Icons.bug_report_rounded)),
          onTap: () => context.safeLaunchURL(
            "mailto:heartryapp@gmail.com?&subject=Bug report",
            name: "Bug report email",
          ),
        ),
        ListTile(
          title: const Text("Share"),
          subtitle: const Text("Share it with your friends and family."),
          leading: const CircleAvatar(child: Icon(Icons.share)),
          onTap: () => SharePlus.instance.share(
            ShareParams(
              text:
                  "Hey, kindly checkout Heartry - An app for Writers on playstore at https://play.google.com/store/apps/details?id=com.darshan.heartry",
            ),
          ),
        ),
      ],
    );
  }
}
