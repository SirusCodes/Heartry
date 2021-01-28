import 'dart:io';

import 'package:flutter/material.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import 'widgets/contributors.dart';
import 'widgets/others.dart';
import 'widgets/support_development.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
