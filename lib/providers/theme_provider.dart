import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/theme.dart';
import 'shared_prefs_provider.dart';

final themeProvider =
    StateNotifierProvider<ThemeProvider, AsyncValue<ThemeDetail>>(
        ThemeProvider.new);

class ThemeDetail {
  const ThemeDetail({required this.themeType, required this.accentColor});

  final ThemeType themeType;
  final Color? accentColor;

  ThemeDetail removeAccentColor() {
    return ThemeDetail(themeType: themeType, accentColor: null);
  }

  ThemeDetail copyWith({ThemeType? themeType, Color? accentColor}) {
    return ThemeDetail(
      themeType: themeType ?? this.themeType,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  int get hashCode => themeType.hashCode ^ accentColor.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ThemeDetail &&
        themeType == other.themeType &&
        accentColor == other.accentColor;
  }
}

class ThemeProvider extends StateNotifier<AsyncValue<ThemeDetail>> {
  ThemeProvider(Ref ref) : super(const AsyncLoading()) {
    ref.read(sharedPrefsProvider.future).then((sharedPrefs) {
      _sharedPreferences = sharedPrefs;
      _init();
    });
  }

  static const _themeKey = "theme";
  static const _accentColorKey = "accentColor";

  late SharedPreferences _sharedPreferences;

  void _init() {
    final accentColor = _sharedPreferences.getInt(_accentColorKey);
    final themeDetails = ThemeDetail(
      themeType: ThemeType.fromString(_sharedPreferences.getString(_themeKey)),
      accentColor: accentColor != null ? Color(accentColor) : null,
    );

    state = AsyncData(themeDetails);
  }

  void setTheme(ThemeType theme) {
    _sharedPreferences.setString(_themeKey, theme.toString());
    state = AsyncData(state.asData!.value.copyWith(themeType: theme));
  }

  void setAccentColor(Color color) {
    _sharedPreferences.setInt(_accentColorKey, color.value);
    state = AsyncData(state.asData!.value.copyWith(accentColor: color));
  }

  void setToDynamicColor() {
    _sharedPreferences.remove(_accentColorKey);
    state = AsyncData(state.asData!.value.removeAccentColor());
  }
}
