import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/config.dart';
import 'init_get_it.dart';
import 'providers/shared_prefs_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/intro_screen/intro_screen.dart';
import 'screens/poems_screen/poems_screen.dart';
import 'utils/custom_email_report_handler.dart';
import 'utils/theme.dart';

Future<void> main() async {
  initGetIt();
  WidgetsFlutterBinding.ensureInitialized();

  final releaseCatcher = CatcherOptions(
    DialogReportMode(),
    [
      CustomEmailReportHandler(),
    ],
  );

  final _sharedPrefs = await SharedPreferences.getInstance();
  Catcher(
    releaseConfig: releaseCatcher,
    profileConfig: releaseCatcher,
    rootWidget: ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(SharedPrefsProvider(_sharedPrefs))
      ],
      child: MyApp(),
    ),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final config = watch(configProvider);
    return MaterialApp(
      title: "Heartry",
      navigatorKey: Catcher.navigatorKey,
      themeMode: _getThemeMode(theme),
      theme: lightTheme,
      darkTheme: _getDarkTheme(theme),
      home: config.name != null ? const PoemScreen() : const IntroScreen(),
    );
  }

  ThemeMode _getThemeMode(ThemeType theme) {
    switch (theme) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
      case ThemeType.black:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData _getDarkTheme(ThemeType theme) {
    if (theme == ThemeType.dark) return darkTheme;
    return blackTheme;
  }
}
