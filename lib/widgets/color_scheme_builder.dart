import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../utils/theme.dart';

typedef ColorSchemeBuilderFunction = Widget Function(
  ColorScheme lightColorScheme,
  ColorScheme darkColorScheme,
);

class ColorSchemeBuilder extends StatelessWidget {
  const ColorSchemeBuilder({
    super.key,
    required this.builder,
    required this.accentColor,
  });

  final ColorSchemeBuilderFunction builder;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    if (accentColor != null) {
      return builder(
        ColorScheme.fromSeed(
          seedColor: accentColor!,
          brightness: Brightness.light,
        ),
        ColorScheme.fromSeed(
          seedColor: accentColor!,
          brightness: Brightness.dark,
        ),
      );
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme, darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = heartryLightColorScheme;
          darkColorScheme = heartryDarkColorScheme;
        }

        return builder(lightColorScheme, darkColorScheme);
      },
    );
  }
}
