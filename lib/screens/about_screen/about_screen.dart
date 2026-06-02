import 'package:flutter/material.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/constrained_width_container.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import 'widgets/contributors.dart';
import 'widgets/others.dart';
import 'widgets/support_development.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String routePath = '/about';

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: ConstrainedWidthContainer(
          child: ListView(
            children: const <Widget>[
              CScreenTitle(title: "About"),
              Contributors(),
              SupportDevelopment(),
              Others(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
