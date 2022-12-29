import 'package:flutter/material.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../about_screen/about_screen.dart';
import '../personalize_theme/personalize_theme.dart';
import '../profile_screen/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const CScreenTitle(
              title: "Settings",
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text("Profile"),
              subtitle: const Text("Name and picture"),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.palette)),
              title: const Text("Personalize"),
              subtitle: const Text("Theme and defaults"),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const PersonalizeScreen()),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.info)),
              title: const Text("About"),
              subtitle: const Text("App info and development"),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
