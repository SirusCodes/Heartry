import 'dart:io';

import 'package:flutter/material.dart';

import 'only_back_button_bottom_app_bar.dart';

const data = """

• Your privacy is of utmost importance to us.

• Your data will be stored only on your device and will never leave it.

• In case the app crashes, you will be given a choice to share the crash details with us, which will include some of your device's specifications, but will NOT be sufficient to uniquely identify you or your device.

• We do not use trackers.

• We do not collect any personal data.""";

class PrivacyStatement extends StatelessWidget {
  const PrivacyStatement({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            Text(
              "⨕ We don't collect any data! 🥳",
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Text(
              data,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
