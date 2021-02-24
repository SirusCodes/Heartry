import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../about_screen/widgets/base_info_widget.dart';

class PersonalizeScreen extends ConsumerWidget {
  const PersonalizeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _theme = watch(themeProvider).state;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            const CScreenTitle(title: "Personalize"),
            BaseInfoWidget(
              title: "Theme",
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.palette)),
                  title: const Text("Theme"),
                  subtitle: Text(_getThemeName(_theme)),
                  onTap: () async {
                    final theme = await _showThemeDialog(context, _theme);
                    if (theme != null)
                      context.read(themeProvider).state = theme;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }

  String _getThemeName(ThemeType theme) {
    switch (theme) {
      case ThemeType.light:
        return "Light";
      case ThemeType.dark:
        return "Dark";
      case ThemeType.black:
        return "Black";
      default:
        return "System Default";
    }
  }

  Future<ThemeType> _showThemeDialog(BuildContext context, ThemeType selected) {
    return showDialog<ThemeType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Theme"),
        children: [
          RadioListTile<ThemeType>(
            title: const Text("System Default"),
            value: ThemeType.system,
            groupValue: selected,
            onChanged: (theme) => _onThemeChanged(context, theme),
          ),
          RadioListTile<ThemeType>(
            title: const Text("Light"),
            value: ThemeType.light,
            groupValue: selected,
            onChanged: (theme) => _onThemeChanged(context, theme),
          ),
          RadioListTile<ThemeType>(
            title: const Text("Dark"),
            value: ThemeType.dark,
            groupValue: selected,
            onChanged: (theme) => _onThemeChanged(context, theme),
          ),
          RadioListTile<ThemeType>(
            title: const Text("Black"),
            value: ThemeType.black,
            groupValue: selected,
            onChanged: (theme) => _onThemeChanged(context, theme),
          ),
        ],
      ),
    );
  }

  void _onThemeChanged(BuildContext context, ThemeType theme) {
    return Navigator.pop(context, theme);
  }
}
