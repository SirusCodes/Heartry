import 'package:flutter/material.dart';

enum ThemeType { light, dark, black, system }

String themeToString(ThemeType theme) {
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

ThemeType stringToTheme(String theme) {
  switch (theme) {
    case "Light":
      return ThemeType.light;
    case "Dark":
      return ThemeType.dark;
    case "Black":
      return ThemeType.black;
    default:
      return ThemeType.system;
  }
}

final lightTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.deepPurple.shade50,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
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
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
  accentColor: Colors.deepPurpleAccent.shade100,
  primaryColor: Colors.deepPurple.withOpacity(.5),
  primaryColorBrightness: Brightness.dark,
  primaryColorDark: Colors.deepPurpleAccent.shade100,
  toggleableActiveColor: Colors.deepPurpleAccent,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10.0),
      backgroundColor: Colors.deepPurple.shade50.withOpacity(.7),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurpleAccent.shade100,
  ),
  accentTextTheme: TextTheme(
    headline3: TextStyle(
      color: Colors.deepPurple.shade50.withOpacity(.8),
    ),
    headline4: const TextStyle(
      fontWeight: FontWeight.w400,
    ),
    headline5: TextStyle(
      color: Colors.deepPurple.shade900,
    ),
    headline6: const TextStyle(
      fontWeight: FontWeight.w400,
    ),
    subtitle1: TextStyle(
      color: Colors.deepPurple.shade700,
    ),
    bodyText1: TextStyle(
      color: Colors.deepPurpleAccent.shade100,
    ),
    bodyText2: TextStyle(
      color: Colors.deepPurpleAccent.shade100,
    ),
  ),
);

final blackTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
  accentColor: Colors.deepPurpleAccent.shade100,
  primaryColor: Colors.deepPurple.withOpacity(.5),
  primaryColorBrightness: Brightness.dark,
  primaryColorDark: Colors.deepPurpleAccent.shade100,
  toggleableActiveColor: Colors.deepPurpleAccent,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      side: BorderSide(color: Colors.deepPurple.shade50.withOpacity(.4)),
      padding: const EdgeInsets.all(10.0),
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurpleAccent.shade100,
  ),
  accentTextTheme: TextTheme(
    headline3: TextStyle(
      color: Colors.deepPurple.shade50.withOpacity(.8),
    ),
    headline4: const TextStyle(
      fontWeight: FontWeight.w400,
    ),
    headline5: TextStyle(
      color: Colors.deepPurple.shade50,
      fontWeight: FontWeight.w400,
    ),
    headline6: const TextStyle(
      fontWeight: FontWeight.w400,
    ),
    subtitle1: TextStyle(
      color: Colors.deepPurple.shade100,
    ),
    bodyText1: TextStyle(
      color: Colors.deepPurpleAccent.shade100,
    ),
    bodyText2: TextStyle(
      color: Colors.deepPurpleAccent.shade100,
    ),
  ),
);
