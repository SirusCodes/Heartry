import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/config.dart';
import 'init_get_it.dart';
import 'providers/theme_provider.dart';
import 'screens/intro_screen/intro_screen.dart';
import 'screens/poems_screen/poems_screen.dart';
import 'utils/theme.dart';
import 'utils/workmanager_helper.dart';
import 'widgets/color_scheme_builder.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  initGetIt();
  initWorkmanager();

  await SentryFlutter.init(
    (options) {
      options.dsn = String.fromEnvironment("SENTRY_DSN", defaultValue: "");
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.2;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
      options.autoInitializeNativeSdk = true;
    },
    appRunner: () =>
        runApp(SentryWidget(child: const ProviderScope(child: MyApp()))),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                themeMode: _getThemeMode(theme.themeType),
                theme: getLightTheme(lightColorScheme),
                darkTheme: theme.themeType == ThemeType.dark
                    ? getDarkTheme(darkColorScheme)
                    : getBlackTheme(darkColorScheme),
                home: Consumer(
                  builder: (context, ref, _) {
                    return ref
                        .watch(configProvider)
                        .when(
                          data: (config) {
                            if (config.hasCompletedOnboarding)
                              return const PoemScreen();

                            return const IntroScreen();
                          },
                          error: (err, st) =>
                              Center(child: Text("$err\n${"_" * 25}\n$st")),
                          loading: () => const Material(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                  },
                ),
              );
            },
          ),
          loading: () =>
              const Material(child: Center(child: CircularProgressIndicator())),
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
