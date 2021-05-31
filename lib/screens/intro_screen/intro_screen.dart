import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_swipe/liquid_swipe.dart';

import 'widgets/backup_widget.dart';
import 'widgets/name_widget.dart';
import 'widgets/profile_widget.dart';
import 'widgets/welcome_widget.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _enableSlideIcon = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidSwipe(
        pages: const [
          WelcomeWidget(),
          BackupOrRestoreWidget(),
          ProfileWidget(),
          NameWidget(),
        ],
        enableLoop: false,
        onPageChangeCallback: (activePageIndex) {
          setState(() {
            _enableSlideIcon = activePageIndex != 3;
          });
        },
        positionSlideIcon: .5,
        ignoreUserGestureWhileAnimating: true,
        slideIconWidget: _enableSlideIcon
            ? const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 40,
              )
            : null,
      ),
    );
  }
}
