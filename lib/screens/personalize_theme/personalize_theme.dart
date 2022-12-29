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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: const <Widget>[
            CScreenTitle(title: "Personalize"),
            _Body(),
          ],
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    return theme.when(
      data: (currentTheme) => BaseInfoWidget(
        title: "THEME",
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.palette)),
            title: const Text("Theme"),
            subtitle: Text(currentTheme.toString()),
            onTap: () async {
              final theme = context.read(themeProvider.notifier);
              final selectedTheme =
                  await _showThemeDialog(context, currentTheme);
              if (selectedTheme != null) theme.setTheme(selectedTheme);
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
