import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_info_widget.dart';

const _profileURL =
    "https://media-exp1.licdn.com/dms/image/C5103AQEtWUqi83pq-g/profile-displayphoto-shrink_400_400/0/1569059140972?e=1617235200&v=beta&t=h7NoI5ygZs_IQeDepkfbBpqtWuQjljYu44eGPQHNYSk";

class Contributors extends StatelessWidget {
  const Contributors({Key key}) : super(key: key);

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
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Column darshanInfo(BuildContext context) {
    return Column(
      children: <Widget>[
        const CircleAvatar(
          minRadius: 50,
          maxRadius: 60,
          backgroundImage: NetworkImage(_profileURL),
        ),
        const SizedBox(height: 10),
        Text(
          "Darshan Rander",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          "Lead Developer & Designer",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ],
    );
  }
}
