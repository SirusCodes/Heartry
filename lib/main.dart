import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/config.dart';
import 'init_get_it.dart';
import 'providers/theme_provider.dart';
import 'screens/intro_screen/intro_screen.dart';
import 'screens/poems_screen/poems_screen.dart';
import 'utils/custom_email_report_handler.dart';
import 'utils/theme.dart';

Future<void> main() async {
  initGetIt();

  final releaseCatcher = CatcherOptions(
    DialogReportMode(),
    [
      CustomEmailReportHandler(),
    ],
  );

  Catcher(
    releaseConfig: releaseCatcher,
    profileConfig: releaseCatcher,
    rootWidget: ProviderScope(child: MyApp()),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initSharedPrefs;

  @override
  void initState() {
    super.initState();
    _initSharedPrefs = locator<Config>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final _theme = watch(themeProvider);
        return _theme.when(
          data: (theme) => MaterialApp(
            title: "Heartry",
            navigatorKey: Catcher.navigatorKey,
            themeMode: _getThemeMode(theme),
            theme: lightTheme,
            darkTheme: _getDarkTheme(theme),
            home: FutureBuilder(
              future: _initSharedPrefs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final _name = locator<Config>().name;

                  if (_name != null) return const PoemScreen();

                  return const IntroScreen();
                }

                return const Material(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          loading: () => const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, st) {
            throw Exception("$err\n${"_" * 25}\nst");
          },
        );
      },
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
    if (theme == ThemeType.black) return blackTheme;
    return darkTheme;
  }
}
