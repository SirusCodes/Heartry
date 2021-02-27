import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

final _sharedPrefsProvider = FutureProvider<SharedPreferences>((_) {
  return SharedPreferences.getInstance();
});

final themeProvider = StateNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider(ref.read);
});

class ThemeProvider extends StateNotifier<AsyncValue<ThemeType>> {
  ThemeProvider(Reader read) : super(const AsyncLoading()) {
    read(_sharedPrefsProvider.future).then((sharedPrefs) {
      _sharedPreferences = sharedPrefs;
      _init();
    });
  }

  static const _themeKey = "theme";

  SharedPreferences _sharedPreferences;

  void _init() {
    state = AsyncData(stringToTheme(_sharedPreferences.getString(_themeKey)));
  }

  void setTheme(ThemeType theme) {
    _sharedPreferences.setString(_themeKey, themeToString(theme));
    state = AsyncData(theme);
  }
}
