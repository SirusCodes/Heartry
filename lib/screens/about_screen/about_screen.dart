import 'package:flutter/material.dart';

import 'widgets/contributors.dart';
import 'widgets/support_development.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "About",
                style: Theme.of(context)
                    .accentTextTheme
                    .headline3
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Contributors(),
            const SupportDevelopment()
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
}
