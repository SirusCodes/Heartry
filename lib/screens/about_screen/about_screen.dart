import 'package:flutter/material.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import 'widgets/contributors.dart';
import 'widgets/others.dart';
import 'widgets/support_development.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: const <Widget>[
            CScreenTitle(title: "About"),
            Contributors(),
            SupportDevelopment(),
            Others(),
          ],
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
