import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/theme.dart';
import 'shared_prefs_provider.dart';

final themeProvider =
    StateNotifierProvider<ThemeProvider, AsyncValue<ThemeType>>((ref) {
  return ThemeProvider(ref.read);
});

class ThemeProvider extends StateNotifier<AsyncValue<ThemeType>> {
  ThemeProvider(Reader read) : super(const AsyncLoading()) {
    read(sharedPrefsProvider.future).then((sharedPrefs) {
      _sharedPreferences = sharedPrefs;
      _init();
    });
  }

  static const _themeKey = "theme";

  late SharedPreferences _sharedPreferences;

  void _init() {
    state = AsyncData(
        ThemeType.fromString(_sharedPreferences.getString(_themeKey)));
  }

  void setTheme(ThemeType theme) {
    _sharedPreferences.setString(_themeKey, theme.toString());
    state = AsyncData(theme);
  }
}
