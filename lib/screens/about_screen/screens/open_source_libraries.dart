import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> ossNames = [
  "animated_icon_button",
  "animations",
  "builders",
  "cupertino_icons",
  "flutter_colorpicker",
  "flutter_riverpod",
  "json_annotation",
  "json_serializable",
  "lint",
  "url_launcher",
  "waterfall_flow",
];

class OpenSourceLibraries extends StatelessWidget {
  const OpenSourceLibraries({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            Text(
              "Licences",
              style: Theme.of(context)
                  .accentTextTheme
                  .headline3
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            ...ossNames.map(
              (e) => TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => _launchURL(e),
                child: Text(
                  e,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String name) async {
    final url = "https://pub.dev/packages/$name";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
