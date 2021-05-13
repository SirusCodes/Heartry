import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/theme.dart';
import 'shared_prefs_provider.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeType>((ref) {
  return ThemeProvider(ref.watch(sharedPrefsProvider));
});

class ThemeProvider extends StateNotifier<ThemeType> {
  ThemeProvider(this.sharedPreferences) : super(_getTheme(sharedPreferences));

  static const _themeKey = "theme";

  final SharedPreferences sharedPreferences;

  static ThemeType _getTheme(SharedPreferences sharedPreferences) =>
      stringToTheme(sharedPreferences.getString(_themeKey));

  String? get themeString => sharedPreferences.getString(_themeKey);

  void setTheme(ThemeType theme) {
    sharedPreferences.setString(_themeKey, themeToString(theme));
    state = theme;
  }
}
