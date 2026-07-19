import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/url_launcher_helper.dart';
import 'base_info_widget.dart';

const _profileURL = "https://darshanrander.com/darshan-min.jpg";

class Contributors extends StatefulWidget {
  const Contributors({super.key});

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
            context.safeLaunchURL(
              "https://darshanrander.com",
              name: "Darshan Rander",
              mode: LaunchMode.externalApplication,
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
          backgroundImage: !_profileError
              ? const NetworkImage(_profileURL)
              : null,
          child: _profileError ? const Icon(Icons.person, size: 80) : null,
        ),
        const SizedBox(height: 10),
        Text(
          "Darshan Rander",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          "Lead Developer",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
