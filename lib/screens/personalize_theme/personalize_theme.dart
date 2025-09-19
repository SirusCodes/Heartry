import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/color_picker_dialog.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../about_screen/widgets/base_info_widget.dart';

class PersonalizeScreen extends StatelessWidget {
  const PersonalizeScreen({super.key});

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
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeDetail = ref.watch(themeProvider);

    return themeDetail.when(
      data: (currentTheme) => BaseInfoWidget(
        title: "THEME",
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.palette)),
            title: const Text("Theme"),
            subtitle: Text(currentTheme.themeType.toString()),
            onTap: () async {
              final theme = ref.read(themeProvider.notifier);
              final selectedTheme =
                  await _showThemeDialog(context, currentTheme.themeType);
              if (selectedTheme != null) theme.setTheme(selectedTheme);
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.format_color_fill_rounded),
            ),
            title: const Text("Accent Color"),
            onTap: () => showColorPickerWithDynamic(
              context: context,
              currentColor: currentTheme.accentColor,
              onOkPressed: (color, isDynamic) {
                final theme = ref.read(themeProvider.notifier);
                if (isDynamic)
                  theme.setToDynamicColor();
                else
                  theme.setAccentColor(color);
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => throw Exception("$err\n${"_" * 25}\nst"),
    );
  }

  Future<ThemeType?> _showThemeDialog(
    BuildContext context,
    ThemeType selected,
  ) {
    return showDialog<ThemeType>(
      context: context,
      builder: (context) => RadioGroup<ThemeType>(
        groupValue: selected,
        onChanged: (theme) => _onThemeChanged(context, theme),
        child: SimpleDialog(
          title: const Text("Select Theme"),
          children: [
            RadioListTile<ThemeType>(
              title: const Text("System Default"),
              value: ThemeType.system,
            ),
            RadioListTile<ThemeType>(
              title: const Text("Light"),
              value: ThemeType.light,
            ),
            RadioListTile<ThemeType>(
              title: const Text("Dark"),
              value: ThemeType.dark,
            ),
            RadioListTile<ThemeType>(
              title: const Text("Black"),
              value: ThemeType.black,
            ),
          ],
        ),
      ),
    );
  }

  void _onThemeChanged(BuildContext context, ThemeType? theme) {
    return Navigator.pop(context, theme);
  }
}
