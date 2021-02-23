import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeType { light, dark, black, system }

final themeProvider = StateProvider<ThemeType>((_) => ThemeType.system);
