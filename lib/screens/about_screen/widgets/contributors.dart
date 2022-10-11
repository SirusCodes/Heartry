import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'base_info_widget.dart';

const _profileURL =
    "https://secure.gravatar.com/avatar/81d9c078a3dfb1cda130020eecfc6e56?s=500";

class Contributors extends StatefulWidget {
  const Contributors({Key? key}) : super(key: key);

  @override
  State<Contributors> createState() => _ContributorsState();
}

class _ContributorsState extends State<Contributors> {
  bool _profileError = false;

  @override
  Widget build(BuildContext context) {
    return BaseInfoWidget(
      title: "CONTRIBUTORS",
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            _launchURL(
              "https://www.linkedin.com/in/darshan-rander-b28a3b193/",
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: darshanInfo(context),
          ),
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

  Column darshanInfo(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          minRadius: 50,
          maxRadius: 60,
          onBackgroundImageError: (exception, stackTrace) {
            if (exception is SocketException) {
              setState(() {
                _profileError = true;
              });
              return;
            }
            throw Exception(stackTrace);
          },
          backgroundImage:
              !_profileError ? const NetworkImage(_profileURL) : null,
          child: _profileError
              ? const Icon(
                  Icons.person,
                  size: 80,
                )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          "Darshan Rander",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          "Lead Developer",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ],
    );
  }
}
