import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/theme.dart';
import 'shared_prefs_provider.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeType>((ref) {
  return ThemeProvider(ref.watch(sharedPrefsProvider));
});

class ThemeProvider extends StateNotifier<ThemeType> {
  ThemeProvider(this.sharedPrefsProvider)
      : super(_getTheme(sharedPrefsProvider));

  final SharedPrefsProvider sharedPrefsProvider;

  static ThemeType _getTheme(SharedPrefsProvider sharedPreferences) =>
      stringToTheme(sharedPreferences.theme);

  void setTheme(ThemeType theme) {
    sharedPrefsProvider.theme = themeToString(theme);
    state = theme;
  }
}
