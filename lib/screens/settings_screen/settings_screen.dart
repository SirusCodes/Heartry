import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/constrained_width_container.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../profile_screen/profile_screen.dart';
import '../personalize_theme/personalize_theme.dart';
import '../backup_setting_screen/backup_setting_screen.dart';
import '../bin_screen/bin_screen.dart';
import '../about_screen/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: ConstrainedWidthContainer(
          child: ListView(
            children: [
              const CScreenTitle(title: "Settings"),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text("Profile"),
                subtitle: const Text("Name and picture"),
                onTap: () => context.push(ProfileScreen.routePath),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.palette)),
                title: const Text("Personalize"),
                subtitle: const Text("Theme and defaults"),
                onTap: () => context.push(PersonalizeScreen.routePath),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.cloud_sync)),
                title: const Text("Backup and Restore"),
                subtitle: const Text("Info on your Google Drive backup"),
                onTap: () => context.push(BackupSettingScreen.routePath),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Symbols.delete_rounded),
                ),
                title: const Text("Bin"),
                subtitle: const Text("Restore from bin or delete permanently"),
                onTap: () => context.push(BinScreen.routePath),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.info)),
                title: const Text("About"),
                subtitle: const Text("App info and development"),
                onTap: () => context.push(AboutScreen.routePath),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
