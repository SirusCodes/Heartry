import 'package:flutter/material.dart';

enum ThemeType {
  light("Light"),
  dark("Dark"),
  black("Black"),
  system("System Default");

  const ThemeType(this.value);

  final String value;

  @override
  String toString() {
    return value;
  }

  static ThemeType fromString(String? value) {
    switch (value) {
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
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      side: BorderSide(color: _lightColorScheme.primary),
      backgroundColor: _lightColorScheme.secondaryContainer,
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10.0),
      backgroundColor: _darkColorScheme.secondaryContainer,
    ),
  ),
);

final blackTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _blackColorScheme,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10.0),
      side: BorderSide(color: _blackColorScheme.secondaryContainer, width: 2),
    ),
  ),
);

const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF714BA5),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFEDDCFF),
  onPrimaryContainer: Color(0xFF290055),
  secondary: Color(0xFF645A70),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFEBDDF7),
  onSecondaryContainer: Color(0xFF20182A),
  tertiary: Color(0xFF7F525A),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD9DF),
  onTertiaryContainer: Color(0xFF321019),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF1D1B1E),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1D1B1E),
  surfaceVariant: Color(0xFFE8E0EB),
  onSurfaceVariant: Color(0xFF4A454E),
  outline: Color(0xFF7B757F),
  onInverseSurface: Color(0xFFF5EFF4),
  inverseSurface: Color(0xFF322F33),
  inversePrimary: Color(0xFFD8B9FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF714BA5),
  outlineVariant: Color(0xFFCCC4CF),
  scrim: Color(0xFF000000),
);

const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD8B9FF),
  onPrimary: Color(0xFF411774),
  primaryContainer: Color(0xFF59328C),
  onPrimaryContainer: Color(0xFFEDDCFF),
  secondary: Color(0xFFCFC2DA),
  onSecondary: Color(0xFF352D40),
  secondaryContainer: Color(0xFF4C4357),
  onSecondaryContainer: Color(0xFFEBDDF7),
  tertiary: Color(0xFFF2B7C1),
  onTertiary: Color(0xFF4B252D),
  tertiaryContainer: Color(0xFF653B43),
  onTertiaryContainer: Color(0xFFFFD9DF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1D1B1E),
  onBackground: Color(0xFFE7E1E5),
  surface: Color(0xFF1D1B1E),
  onSurface: Color(0xFFE7E1E5),
  surfaceVariant: Color(0xFF4A454E),
  onSurfaceVariant: Color(0xFFCCC4CF),
  outline: Color(0xFF958E99),
  onInverseSurface: Color(0xFF1D1B1E),
  inverseSurface: Color(0xFFE7E1E5),
  inversePrimary: Color(0xFF714BA5),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD8B9FF),
  outlineVariant: Color(0xFF4A454E),
  scrim: Color(0xFF000000),
);

const _blackColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD8B9FF),
  onPrimary: Color(0xFF411774),
  primaryContainer: Color(0xFF59328C),
  onPrimaryContainer: Color(0xFFEDDCFF),
  secondary: Color(0xFFCFC2DA),
  onSecondary: Color(0xFF352D40),
  secondaryContainer: Color(0xFF4C4357),
  onSecondaryContainer: Color(0xFFEBDDF7),
  tertiary: Color(0xFFF2B7C1),
  onTertiary: Color(0xFF4B252D),
  tertiaryContainer: Color(0xFF653B43),
  onTertiaryContainer: Color(0xFFFFD9DF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF000000),
  onBackground: Color(0xFFE7E1E5),
  surface: Color(0xFF1D1B1E),
  onSurface: Color(0xFFE7E1E5),
  surfaceVariant: Color(0xFF4A454E),
  onSurfaceVariant: Color(0xFFCCC4CF),
  outline: Color(0xFF958E99),
  onInverseSurface: Color(0xFF1D1B1E),
  inverseSurface: Color(0xFFE7E1E5),
  inversePrimary: Color(0xFF714BA5),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD8B9FF),
  outlineVariant: Color(0xFF4A454E),
  scrim: Color(0xFF000000),
);
