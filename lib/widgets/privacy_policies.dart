import 'package:flutter/material.dart';
import 'package:heartry/widgets/only_back_button_bottom_app_bar.dart';

const data =
    // ignore: lines_longer_than_80_chars
    "\nWe are very concerned about your privacy. Hence anything you do in the application will be stored on your device and will never leave your device." +
        // ignore: lines_longer_than_80_chars
        "\n\nThere are absolutely no trackers in the app, so we expect in case of any crash a dialog box will be shown by which you can send us the detailed analysis of the crash so we can improve the app for everyone.";

class PrivacyPolicies extends StatelessWidget {
  const PrivacyPolicies({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            Text(
              "⨕ We don't collect any data!!🥳",
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              data,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const OnlyBackButtonBottomAppBar(),
    );
  }
}
