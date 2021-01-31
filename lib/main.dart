import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/all.dart';

import 'database/config.dart';
import 'init_get_it.dart';
import 'screens/intro_screen/intro_screen.dart';
import 'screens/poems_screen/poems_screen.dart';
import 'utils/custom_email_report_handler.dart';

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
  Future<void> _initSharedPrefs;
  @override
  void initState() {
    super.initState();
    _initSharedPrefs = locator<Config>().init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Heartry",
      navigatorKey: Catcher.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(10.0),
            ),
            backgroundColor: MaterialStateProperty.all(
              Colors.deepPurple.shade50,
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.deepPurple.shade100,
            ),
          ),
        ),
        accentTextTheme: TextTheme(
          headline2: const TextStyle(
            color: Colors.deepPurpleAccent,
          ),
          headline3: const TextStyle(
            color: Colors.deepPurpleAccent,
          ),
          headline4: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w400,
          ),
          headline5: const TextStyle(
            color: Colors.deepPurpleAccent,
          ),
          headline6: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w400,
          ),
          subtitle1: TextStyle(
            color: Colors.deepPurpleAccent.shade100,
          ),
          bodyText1: TextStyle(
            color: Colors.deepPurpleAccent.shade100,
          ),
          bodyText2: TextStyle(
            color: Colors.deepPurpleAccent.shade100,
          ),
        ),
      ),
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
    );
  }
}
