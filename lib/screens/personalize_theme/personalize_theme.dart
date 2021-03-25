import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../about_screen/widgets/base_info_widget.dart';

class PersonalizeScreen extends StatelessWidget {
  const PersonalizeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: const <Widget>[
            CScreenTitle(title: "Personalize"),
            _Body(),
          ],
        ),
      ),
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _theme = watch(themeProvider.state);
    return _theme.when(
      data: (theme) => BaseInfoWidget(
        title: "Theme",
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.palette)),
            title: const Text("Theme"),
            subtitle: Text(themeToString(theme)),
            onTap: () async {
              final selectedTheme = await _showThemeDialog(context, theme);
              if (selectedTheme != null)
                context.read(themeProvider).setTheme(selectedTheme);
            },
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => throw Exception("$err\n${"_" * 25}\nst"),
    );
  }

  Future<ThemeType?> _showThemeDialog(
      BuildContext context, ThemeType selected) {
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

  void _onThemeChanged(BuildContext context, ThemeType? theme) {
    return Navigator.pop(context, theme);
  }
}
