import 'package:catcher_2/catcher_2.dart';
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
import 'utils/workmanager_helper.dart';
import 'widgets/color_scheme_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initGetIt();
  initWorkmanager();

  final releaseCatcher = Catcher2Options(
    DialogReportMode(),
    [
      CustomEmailReportHandler(),
    ],
  );

  Catcher2(
    releaseConfig: releaseCatcher,
    profileConfig: releaseCatcher,
    ensureInitialized: true,
    rootWidget: const ProviderScope(child: MyApp()),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeDetail = ref.watch(themeProvider);

        return themeDetail.when(
          data: (theme) => ColorSchemeBuilder(
            accentColor: theme.accentColor,
            builder: (lightColorScheme, darkColorScheme) {
              return MaterialApp(
                title: "Heartry",
                navigatorKey: Catcher2.navigatorKey,
                themeMode: _getThemeMode(theme.themeType),
                theme: getLightTheme(lightColorScheme),
                darkTheme: theme.themeType == ThemeType.dark
                    ? getDarkTheme(darkColorScheme)
                    : getBlackTheme(darkColorScheme),
                home: Consumer(
                  builder: (context, ref, _) {
                    return ref.watch(configProvider).when(
                          data: (config) {
                            if (config.hasCompletedOnboarding)
                              return const PoemScreen();

                            return const IntroScreen();
                          },
                          error: (err, st) => Center(
                            child: Text("$err\n${"_" * 25}\n$st"),
                          ),
                          loading: () => const Material(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                  },
                ),
              );
            },
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
}
