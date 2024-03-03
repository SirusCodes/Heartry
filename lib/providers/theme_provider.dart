import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_detail_model/theme_detail_model.dart';
import '../utils/theme.dart';

final themeProvider = AsyncNotifierProvider<ThemeProvider, ThemeDetailModel>(
  () => ThemeProvider(),
);

class ThemeProvider extends AsyncNotifier<ThemeDetailModel> {
  static const _themeKey = "theme";
  static const _accentColorKey = "accentColor";

  late SharedPreferences _sharedPreferences;

  ThemeDetailModel getThemeDetails() {
    final accentColor = _sharedPreferences.getInt(_accentColorKey);
    return ThemeDetailModel(
      themeType: ThemeType.fromString(_sharedPreferences.getString(_themeKey)),
      accentColor: accentColor != null ? Color(accentColor) : null,
    );
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

  @override
  FutureOr<ThemeDetailModel> build() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    return getThemeDetails();
  }
}
